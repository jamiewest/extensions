import '../dependency_injection/service_provider.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import '../logging/logger.dart';
import '../options/options.dart';
import '../primitives/async_disposable.dart';
import '../primitives/cancellation_token.dart';
import '../primitives/disposable.dart';
import 'background_service.dart';
import 'background_service_exception_behavior.dart';
import 'host_application_builder.dart';
import 'host_application_lifetime.dart';
import 'host_builder.dart';
import 'host_lifetime.dart';
import 'host_options.dart';
import 'hosted_service.dart';
import 'hosting_host_builder_extensions.dart';
import 'hosting_logger_extensions.dart';
import 'internal/application_lifetime.dart';

/// A program abstraction.
class Host implements Disposable, AsyncDisposable {
  final Logger _logger;
  final HostLifetime _hostLifetime;
  final ApplicationLifetime _applicationLifetime;
  final HostOptions _options;
  Iterable<HostedService>? _hostedServices;
  bool _stopCalled = false;
  final ServiceProvider _services;

  Host(
    ServiceProvider services,
    HostApplicationLifetime applicationLifetime,
    Logger logger,
    HostLifetime hostLifetime,
    Options<HostOptions> options,
  )   : _services = services,
        _applicationLifetime = applicationLifetime as ApplicationLifetime,
        _logger = logger,
        _hostLifetime = hostLifetime,
        _options = options.value!;

  // The programs configured services.
  ServiceProvider get services => _services;

  /// Start the program.
  Future<void> start([
    CancellationToken? cancellationToken,
  ]) async {
    _logger.starting();

    cancellationToken ??= CancellationToken.none;

    var combinedCancellationTokenSource =
        CancellationTokenSource.createLinkedTokenSource(
      [cancellationToken, _applicationLifetime.applicationStopping],
    );
    var combinedCancellationToken = combinedCancellationTokenSource.token;

    await _hostLifetime.waitForStart(combinedCancellationToken);

    //combinedCancellationToken.throwIfCancellatinoRequested();
    _hostedServices = (services.getServices<HostedService>() as List)
        .map((item) => item as HostedService)
        .toList();

    for (var hostedService in _hostedServices!) {
      // Fire HostedService.start
      await hostedService.start(combinedCancellationToken);

      if (hostedService is BackgroundService) {
        await _tryExecuteBackgroundService(hostedService);
      }
    }

    // Fire HostApplicationLifetime.started
    _applicationLifetime.notifyStarted();
    _logger.started();
  }

  Future<void> _tryExecuteBackgroundService(
    BackgroundService backgroundService,
  ) async {
    try {
      await backgroundService.executeOperation!.value;
    } on Exception catch (e) {
      // When the host is being stopped, it cancels the background services.
      // This isn't an error condition, so don't log it as an error.
      if (_stopCalled && backgroundService.executeOperation!.isCanceled) {
        return;
      }
      _logger.backgroundServiceFaulted(e);
      if (_options.backgroundServiceExceptionBehavior ==
          BackgroundServiceExceptionBehavior.stopHost) {
        _logger.backgroundServiceStoppingHost(e);
        _applicationLifetime.stopApplication();
      }
    }
  }

  /// Attempts to gracefully stop the program.
  Future<void> stop([CancellationToken? cancellationToken]) async {
    _stopCalled = true;
    _logger.stopping();

    cancellationToken ??= CancellationToken.none;

    var cts = CancellationTokenSource(_options.shutdownTimeout);
    //var cts = CancellationTokenSource();
    var linkedCts = CancellationTokenSource.createLinkedTokenSource(
        [cts.token, cancellationToken]);

    var token = linkedCts.token;
    // Trigger HostApplicationLifetime.applicationStopping
    _applicationLifetime.stopApplication();

    var exceptions = <Exception>[];
    if (_hostedServices != null) {
      for (var hostedService
          in List<HostedService>.from(_hostedServices!).reversed) {
        try {
          await hostedService.stop(token);
        } on Exception catch (ex) {
          exceptions.add(ex);
        }
      }
    }

    // Fire IHostApplicationLifetime.Stopped
    _applicationLifetime.notifyStopped();

    try {
      await _hostLifetime.stop(token);
    } on Exception catch (ex) {
      exceptions.add(ex);
    }

    if (exceptions.isNotEmpty) {
      var ex = Exception('One or more hosted services failed to stop.');
      _logger.stoppedWithException(ex);
      throw ex;
    }

    _logger.stopped();
  }

  @override
  void dispose() => disposeAsync();

  @override
  Future<void> disposeAsync() => Future.value();

  /// Initializes a new instance of the [HostBuilder] class with
  /// pre-configured defaults.
  static HostBuilder createDefaultBuilder([List<String>? args]) {
    var builder = HostBuilder();
    return builder.configureDefaults(args);
  }

  static HostApplicationBuilder createApplicationBuilder(
          [List<String>? args]) =>
      HostApplicationBuilder();
}

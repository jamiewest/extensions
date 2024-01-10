import 'dart:async';

import 'package:extensions/src/hosting/hosted_lifecycle_service.dart';

import '../common/async_disposable.dart';
import '../common/cancellation_token.dart';
import '../common/cancellation_token_source.dart';
import '../dependency_injection/service_provider.dart';
import '../logging/logger.dart';
import '../options/options.dart';
import '../common/disposable.dart';
import 'background_service.dart';
import 'background_service_exception_behavior.dart';
import 'host_application_builder.dart';
import 'host_application_builder_settings.dart';
import 'host_application_lifetime.dart';
import 'host_builder.dart';
import 'host_environment.dart';
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
  //final HostEnvironment _hostEnvironment;
  Iterable<HostedService>? _hostedServices;
  Iterable<HostedLifecycleService>? _hostedLifecycleServices;
  bool _hostStarting = false;
  bool _stopCalled = false;
  bool _hostStopped = false;
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
  ///
  /// - HostLifetime.waitForStart
  /// - Services.getService{StartupValidator}().validate()
  /// - HostedLifecycleService.starting
  /// - HostedService.start
  /// - HostedLifecycleService.started
  /// - HostApplicationLifetime.applicationStarted
  Future<void> start([
    CancellationToken? cancellationToken,
  ]) async {
    _logger.starting();

    cancellationToken ??= CancellationToken.none;

    final combinedCancellationTokenSource =
        CancellationTokenSource.createLinkedTokenSource(
      [
        cancellationToken,
        _applicationLifetime.applicationStopping,
      ],
    );
    final combinedCancellationToken = combinedCancellationTokenSource.token;

    await _hostLifetime.waitForStart(combinedCancellationToken);

    combinedCancellationToken.throwIfCancellationRequested();
    _hostedServices = services.getServices<HostedService>();
    _hostedLifecycleServices = getHostLifecycles(_hostedServices!);
    _hostStarting = true;
    bool concurrent = true; // _options.servicesStartConcurrently;
    bool abortOnFirstException = !concurrent;

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
    var linkedCts = CancellationTokenSource.createLinkedTokenSource(
      [
        cts.token,
        cancellationToken,
      ],
    );

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

    // Fire HostApplicationLifetime.stopped
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

  static Future<void> foreachService<T>(
    Iterable<T> services,
    CancellationToken token,
    bool concurrent,
    bool abortOnFirstException,
    List<Exception> exceptions,
    Future<void> Function(T value, CancellationToken token) operation,
  ) async {
    if (concurrent) {
      List<Future<void>> futures = [];

      for (var service in services) {
        Completer<void> completer = Completer<void>();

        try {
          completer.complete(operation(service, token));
        } on Exception catch (ex) {
          exceptions.add(ex);
          continue;
        }

        if (completer.isCompleted) {
        } else {
          futures.add(completer.future);
        }
      }

      if (futures.isNotEmpty) {
        Future<void> groupedFutures = Future.wait(futures);

        try {
          await groupedFutures;
        } on Exception catch (ex) {
          exceptions.add(ex);
        }
      }
    } else {
      for (var service in services) {
        try {
          await operation(service, token);
        } on Exception catch (ex) {
          exceptions.add(ex);
          if (abortOnFirstException) {
            return;
          }
        }
      }
    }
  }

  static List<HostedLifecycleService>? getHostLifecycles(
    Iterable<HostedService> hostedServices,
  ) {
    var result = <HostedLifecycleService>[];
    for (var hostedService in hostedServices) {
      if (hostedService is HostedLifecycleService) {
        result.add(hostedService);
      }
    }
    return result;
  }

  @override
  void dispose() => disposeAsync();

  @override
  Future<void> disposeAsync() => Future.value();

  /// Initializes a new instance of the [HostBuilder] class with
  /// pre-configured defaults.
  static HostBuilder createDefaultBuilder() {
    final builder = HostBuilder();
    return builder.configureDefaults();
  }

  /// Initializes a new instance of the [HostApplicationBuilder] class
  /// with pre-configured defaults.
  static HostApplicationBuilder createApplicationBuilder({
    HostApplicationBuilderSettings? settings,
  }) =>
      HostApplicationBuilder(settings: settings);
}

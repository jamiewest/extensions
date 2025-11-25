import 'dart:async';

import '../dependency_injection/service_provider.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import '../logging/logger.dart';
import '../options/options.dart';
import '../options/validate_on_start.dart';
import '../primitives/aggregate_exception.dart';
import '../system/async_disposable.dart';
import '../system/disposable.dart';
import '../system/threading/cancellation_token.dart';
import '../system/threading/cancellation_token_source.dart';
import 'background_service.dart';
import 'background_service_exception_behavior.dart';
import 'host_application_builder.dart';
import 'host_application_builder_settings.dart';
import 'host_application_lifetime.dart';
import 'host_builder.dart';
import 'host_lifetime.dart';
import 'host_options.dart';
import 'hosted_lifecycle_service.dart';
import 'hosted_service.dart';
import 'hosting_host_builder_extensions.dart';
import 'internal/application_lifetime.dart';
import 'internal/hosting_logger_extensions.dart';

/// A program abstraction.
class Host implements Disposable, AsyncDisposable {
  final Logger _logger;
  final HostLifetime _hostLifetime;
  final ApplicationLifetime _applicationLifetime;
  final HostOptions _options;
  Iterable<HostedService>? _hostedServices;
  Iterable<HostedLifecycleService>? _hostedLifecycleServices;
  bool _hostStarting = false;
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

    final cts = CancellationTokenSource.createLinkedTokenSource(
      [
        cancellationToken,
        _applicationLifetime.applicationStopping,
      ],
    );

    // Apply startup timeout if configured
    if (_options.startupTimeout != null) {
      cts.cancelAfter(_options.startupTimeout!);
    }

    final cancellationToken0 = cts.token;

    await _hostLifetime.waitForStart(cancellationToken0);
    cancellationToken0.throwIfCancellationRequested();

    var exceptions = <Exception>[];

    _hostedServices ??= services.getServices<HostedService>();
    _hostedLifecycleServices = getHostLifecycles(_hostedServices!);
    _hostStarting = true;

    var concurrent = _options.servicesStartConcurrently;
    var abortOnFirstException = !concurrent;

    void logAndRethrow() {
      if (exceptions.isNotEmpty) {
        if (exceptions.length == 1) {
          // Rethrow if it's a single error
          var singleException = exceptions[0];
          _logger.hostedServiceStartupFaulted(singleException);
          throw singleException;
        } else {
          var ex = AggregateException(
            message: 'One or more hosted services failed to start.',
            innerExceptions: exceptions,
          );
          _logger.hostedServiceStartupFaulted(ex);
          throw ex;
        }
      }
    }

    var validator = services.getService<StartupValidator>();
    if (validator != null) {
      try {
        validator.validate();
      } on Exception catch (ex) {
        exceptions.add(ex);

        // Validation errors cause startup to be aborted.
        logAndRethrow();
      }
    }

    // Call starting().
    if (_hostedLifecycleServices != null) {
      await foreachService<HostedLifecycleService>(
        _hostedLifecycleServices!,
        cancellationToken,
        concurrent,
        abortOnFirstException,
        exceptions,
        (service, token) => service.starting(token),
      );

      // Exceptions in starting cause startup to be aborted.
      logAndRethrow();
    }

    // Call start().
    await foreachService<HostedService>(
      _hostedServices!,
      cancellationToken,
      concurrent,
      abortOnFirstException,
      exceptions,
      (service, token) async {
        await service.start(token);

        if (service is BackgroundService) {
          await _tryExecuteBackgroundService(service);
        }
      },
    );

    // Exceptions in start cause startup to be aborted
    logAndRethrow();

    // Call started
    if (_hostedLifecycleServices != null) {
      await foreachService<HostedLifecycleService>(
        _hostedLifecycleServices!,
        cancellationToken,
        concurrent,
        abortOnFirstException,
        exceptions,
        (service, token) => service.started(token),
      );
    }

    // Fire HostApplicationLifetime.started
    // This catches all exceptions and does not re-throw.
    _applicationLifetime.notifyStarted();
    _logger.started();
  }

  Future<void> _tryExecuteBackgroundService(
    BackgroundService backgroundService,
  ) async {
    try {
      await backgroundService.executeOperation!.value;
    } on Exception catch (ex) {
      // When the host is being stopped, it cancels the background services.
      // This isn't an error condition, so don't log it as an error.
      if (_stopCalled && backgroundService.executeOperation!.isCanceled) {
        return;
      }
      _logger.backgroundServiceFaulted(ex);
      if (_options.backgroundServiceExceptionBehavior ==
          BackgroundServiceExceptionBehavior.stopHost) {
        _logger.backgroundServiceStoppingHost(ex);
        // This catches all exceptions and does not re-throw.
        _applicationLifetime.stopApplication();
      }
    }
  }

  /// Attempts to gracefully stop the program.
  // Order:
  //  HostedLifecycleService.stopping
  //  HostApplicationLifetime.applicationStopping
  //  HostedService.stop
  //  HostedLifecycleService.stopped
  //  HostApplicationLifetime.applicationStopped
  //  HostLifetime.stop
  Future<void> stop([CancellationToken? cancellationToken]) async {
    _stopCalled = true;
    _logger.stopping();

    cancellationToken ??= CancellationToken.none;

    CancellationTokenSource? cts;
    if (_options.shutdownTimeout != null) {
      cts = CancellationTokenSource.createLinkedTokenSource([cancellationToken])
        ..cancelAfter(_options.shutdownTimeout!);
      cancellationToken = cts.token;
    }

    if (cts != null) {
      var exceptions = <Exception>[];
      if (!_hostStarting) {
        // Started?

        // Call IHostApplicationLifetime.ApplicationStopping.
        // This catches all exceptions and does not re-throw.
        _applicationLifetime.stopApplication();
      } else {
        assert(
          _hostedServices != null,
          'Hosted services are resolved when host is started.',
        );
        // Ensure hosted services are stopped in LIFO order
        var reversedServices =
            List<HostedService>.from(_hostedServices ?? <HostedService>[])
                .reversed;
        Iterable<HostedLifecycleService>? reversedLifetimeServices =
            List<HostedLifecycleService>.from(
                    _hostedLifecycleServices ?? <HostedLifecycleService>[])
                .reversed;
        var concurrent = _options.servicesStopConcurrently;

        // Call stopping.
        if (reversedLifetimeServices.isNotEmpty) {
          await foreachService<HostedLifecycleService>(
            reversedLifetimeServices,
            cancellationToken,
            concurrent,
            false,
            exceptions,
            (service, token) => service.stopping(token),
          );
        }

        // Call HostApplicationLifetime.applicationStopping.
        // This catches all exceptions and does not re-throw.
        _applicationLifetime.stopApplication();

        if (reversedServices.isNotEmpty) {
          await foreachService<HostedService>(
            reversedServices,
            cancellationToken,
            concurrent,
            false,
            exceptions,
            (service, token) => service.stop(token),
          );
        }

        if (reversedLifetimeServices.isNotEmpty) {
          await foreachService<HostedLifecycleService>(
            reversedLifetimeServices,
            cancellationToken,
            concurrent,
            false,
            exceptions,
            (service, token) => service.stopped(token),
          );
        }
      }
      // Call HostApplicationLifetime.stopped
      // This catches all exceptions and does not re-throw.
      _applicationLifetime.notifyStopped();

      // This may not catch exceptions, so we do it here.
      try {
        await _hostLifetime.stop(cancellationToken);
      } on Exception catch (ex) {
        exceptions.add(ex);
      }

      if (exceptions.isNotEmpty) {
        if (exceptions.length == 1) {
          // Rethrow if it's a single error
          var singleException = exceptions[0];
          _logger.stoppedWithException(singleException);
          throw singleException;
        } else {
          var ex = AggregateException(
            message: 'One or more hosted services failed to stop.',
            innerExceptions: exceptions,
          );
          _logger.stoppedWithException(ex);
          throw ex;
        }
      }
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
      var futures = <Future<void>>[];

      for (var service in services) {
        var completer = Completer<void>();

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
  void dispose() {
    // Dispose the service provider if it implements Disposable
    if (_services is Disposable) {
      (_services as Disposable).dispose();
    }
  }

  @override
  Future<void> disposeAsync() async {
    // Dispose the service provider asynchronously if it implements
    // AsyncDisposable
    if (_services is AsyncDisposable) {
      await (_services as AsyncDisposable).disposeAsync();
    } else if (_services is Disposable) {
      (_services as Disposable).dispose();
    }
  }

  /// Initializes a new instance of the [HostBuilder] class with
  /// pre-configured defaults.
  static HostBuilder createDefaultBuilder() {
    final builder = DefaultHostBuilder();
    return builder.configureDefaults();
  }

  /// Initializes a new instance of the [HostApplicationBuilder] class
  /// with pre-configured defaults.
  static HostApplicationBuilder createApplicationBuilder({
    HostApplicationBuilderSettings? settings,
  }) =>
      HostApplicationBuilder(settings: settings);
}

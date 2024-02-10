import 'dart:async';
import 'dart:math';

import '../options/validate_on_start.dart';

import '../dependency_injection/service_provider_service_extensions.dart';
import 'hosted_lifecycle_service.dart';

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

    final cts = CancellationTokenSource.createLinkedTokenSource(
      [
        cancellationToken,
        _applicationLifetime.applicationStopping,
      ],
    );
    final _cancellationToken = cts.token;

    await _hostLifetime.waitForStart(_cancellationToken);
    _cancellationToken.throwIfCancellationRequested();

    var exceptions = <Exception>[];

    _hostedServices ??= services.getServices<HostedService>();
    _hostedLifecycleServices = getHostLifecycles(_hostedServices!);
    _hostStarting = true;

    bool concurrent = true; // _options.servicesStartConcurrently;
    bool abortOnFirstException = !concurrent;

    void logAndRethrow() {
      if (exceptions.length > 0) {
        if (exceptions.length == 1) {
          // Rethrow if it's a single error
          var singleException = exceptions[0];
          _logger.hostedServiceStartupFaulted(singleException);
          throw singleException;
        } else {
          // TODO: Change exception to AggregateException.
          var ex = Exception(
            'one or more hosted services failed to start',
            // exceptions,
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
          _tryExecuteBackgroundService(service);
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
      cts =
          CancellationTokenSource.createLinkedTokenSource([cancellationToken]);
      cts.cancelAfter(_options.shutdownTimeout!);
      cancellationToken = cts.token;
    }

    if (cts != null) {
      List<Exception> exceptions = <Exception>[];
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
        // TODO: This needs to be cleaned up.
        Iterable<HostedService> reversedServices =
            List<HostedService>.from(_hostedServices ?? <HostedService>[])
                .reversed;
        Iterable<HostedLifecycleService>? reversedLifetimeServices =
            List<HostedLifecycleService>.from(
                    _hostedLifecycleServices ?? <HostedLifecycleService>[])
                .reversed;
        bool concurrent = _options.servicesStopConcurrently;

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

      _hostStopped = true;

      if (exceptions.length > 0) {
        if (exceptions.length == 1) {
          // Rethrow if it's a single error

          Exception singleException = exceptions[0];
          _logger.stoppedWithException(singleException);
          throw singleException;
        } else {
          // TODO: Update when AggregateException is added.
          // var ex = new AggregateException(
          //     "One or more hosted services failed to stop.", exceptions);
          // _logger.StoppedWithException(ex);
          // throw ex;
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

  static Future<void> _foreachService<T>(
    Iterable<T> services,
    CancellationToken token,
    bool concurrent,
    bool abortOnFirstException,
    List<Exception> exceptions,
    Future<void> Function(T type, CancellationToken cancellationToken)
        operation,
  ) async {
    if (concurrent) {
      List<Future>? futures;

      for (var service in services) {
        var completer = Completer();
        Future<void> future;
        try {
          future = operation(service, token);
          completer.complete(future);
        } on Exception catch (ex) {
          exceptions.add(ex);
          continue;
        }

        if (completer.isCompleted) {
          //if (completer.future.)
        } else {
          // The task encountered an await; add it to a list to
          // run concurrently.
          futures ??= <Future>[];
          futures.add(future);
        }
      }
      if (futures != null) {
        Future<void> groupedFutures = Future.wait(futures);

        try {
          await groupedFutures;
        } on Exception catch (ex) {}
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

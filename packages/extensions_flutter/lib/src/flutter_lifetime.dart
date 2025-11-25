import 'dart:async';
import 'dart:ui';

import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:extensions/system.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_application_wrapper.dart';
import 'flutter_error_handler.dart';
import 'flutter_lifecycle_observer.dart';

class FlutterLifetime implements HostLifetime {
  final FlutterApplicationWrapper _application;
  final ErrorHandler _errorHandler;
  final HostEnvironment _environment;
  final FlutterApplicationLifetime _applicationLifetime;
  final Logger _logger;

  FlutterLifetime(
    FlutterApplicationWrapper application,
    ErrorHandler errorHandler,
    HostEnvironment environment,
    HostApplicationLifetime applicationLifetime,
    LoggerFactory loggerFactory,
  ) : _application = application,
      _errorHandler = errorHandler,
      _environment = environment,
      _applicationLifetime = applicationLifetime as FlutterApplicationLifetime,
      _logger = loggerFactory.createLogger('Hosting.Lifetime');

  HostEnvironment get environment => _environment;

  FlutterApplicationLifetime get applicationLifetime => _applicationLifetime;

  @override
  Future<void> waitForStart(CancellationToken cancellationToken) async {
    if (cancellationToken.isCancellationRequested) {
      throw OperationCanceledException(cancellationToken: cancellationToken);
    }

    final registrations = <CancellationTokenRegistration>[];
    var cancelled = false;

    void cancel(Object? _) {
      cancelled = true;
      for (final registration in registrations) {
        registration.dispose();
      }
      registrations.clear();

      applicationLifetime
        ..applicationPaused.remove(_onPaused)
        ..applicationResumed.remove(_onResumed)
        ..applicationInactive.remove(_onInactive)
        ..applicationHidden.remove(_onHidden)
        ..applicationDetached.remove(_onDetached);
    }

    registrations.add(cancellationToken.register(cancel));

    registrations.add(
      applicationLifetime.applicationStarted.register((state) {
        if (cancelled || cancellationToken.isCancellationRequested) {
          cancel(null);
          return;
        }

        (state as FlutterLifetime)._onApplicationStarted();
      }, this),
    );

    registrations.add(
      applicationLifetime.applicationStopping.register((state) {
        if (cancelled || cancellationToken.isCancellationRequested) {
          cancel(null);
          return;
        }

        (state as FlutterLifetime)._onApplicationStopping();
      }, this),
    );

    applicationLifetime
      ..applicationPaused.add(_onPaused)
      ..applicationResumed.add(_onResumed)
      ..applicationInactive.add(_onInactive)
      ..applicationHidden.add(_onHidden)
      ..applicationDetached.add(_onDetached);

    registrations.add(
      applicationLifetime.applicationStarted.register((_) {
        if (cancelled || cancellationToken.isCancellationRequested) {
          cancel(null);
          return;
        }

        WidgetsFlutterBinding.ensureInitialized();

        FlutterError.onError = _errorHandler.onFlutterError;
        PlatformDispatcher.instance.onError = _errorHandler.onError;

        final app = FlutterLifecycleObserver(
          lifetime: applicationLifetime,
          child: _application.child,
        );

        runApp(app);
      }),
    );

    if (cancellationToken.isCancellationRequested) {
      cancel(null);
      throw OperationCanceledException(cancellationToken: cancellationToken);
    }
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) async =>
      applicationLifetime.stopApplication();

  void _onApplicationStarted() => _logger
    ..logInformation('Application started.')
    ..logInformation('Hosting environment: ${environment.environmentName}');

  void _onApplicationStopping() =>
      _logger.logInformation('Application is shutting down...');

  void _onPaused() => _logger.logDebug('Application paused.');

  void _onResumed() => _logger.logDebug('Application resumed.');

  void _onInactive() => _logger.logDebug('Application is inactive.');

  void _onHidden() => _logger.logDebug('Application is hidden.');

  void _onDetached() => _logger.logDebug('Application is detached.');
}

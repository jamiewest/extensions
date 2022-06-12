import 'dart:async';

import 'package:extensions/hosting.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_lifecycle_observer.dart';
import 'flutter_lifetime_options.dart';

class FlutterLifetime extends HostLifetime {
  final Logger _logger;
  final FlutterApplicationLifetime _lifetime;

  FlutterLifetime({
    required this.app,
    this.options,
    required Logger logger,
    required HostApplicationLifetime lifetime,
    required this.environment,
  })  : _logger = logger,
        _lifetime = lifetime as FlutterApplicationLifetime {
    _lifetime.applicationStarted.register((state) => _onStarted());
    _lifetime.applicationStopping.register((state) => _onStopping());
    _lifetime.applicationStopped.register((state) => _onStopped());
    _lifetime.applicationPaused.register(_onPaused);
    _lifetime.applicationResumed.register(_onResumed);
    _lifetime.applicationInactive.register(_onInactive);
    _lifetime.applicationDetached.register(_onDetached);
  }

  Widget app;

  FlutterLifetimeOptions? options;

  HostEnvironment environment;

  @override
  Future<void> waitForStart(CancellationToken cancellationToken) {
    FlutterError.onError = _handleFlutterError;

    return runZonedGuarded<Future<void>>(
          () async {
            runApp(
              FlutterLifecycleObserver(
                lifetime: _lifetime,
                child: app,
              ),
            );
          },
          (o, s) => _handleError,
        ) ??
        Future.value();
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) => Future.value();

  /// Handles errors caught by the Flutter framework.
  ///
  /// Forwards the error to the [_handleError] handler when in release mode and
  /// prints it to the console otherwise.
  Future<void> _handleFlutterError(FlutterErrorDetails details) async {
    if (options?.flutterErrorHandler != null) {
      await options?.flutterErrorHandler!(details);
    }
  }

  /// Prints the [error] and shows a dialog asking to send the error report.
  ///
  /// Additional device diagnostic data will be sent along the error if the
  /// user consents for it.
  Future<void> _handleError(Object error, StackTrace stackTrace) async {
    if (options?.errorHandler != null) {
      await options?.errorHandler!(error, stackTrace);
    }
  }

  void _onStarted() {
    _logger
      ..logInformation('Application started.')
      ..logInformation('Hosting environment: ${environment.environmentName}');
  }

  void _onStopping() {
    _logger.logInformation('Application is shutting down...');
  }

  void _onStopped() {
    _logger.logInformation('Application stopped.');
  }

  void _onPaused() {
    _logger.logInformation('Application paused.');
  }

  void _onResumed() {
    _logger.logInformation('Application resumed.');
  }

  void _onInactive() {
    _logger.logInformation('Application is inactive...');
  }

  void _onDetached() {
    _logger.logInformation('Application is detached...');
  }
}

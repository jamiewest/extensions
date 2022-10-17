import 'dart:async';
import 'dart:ui';

import 'package:extensions/hosting.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_hosting_environment.dart';
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
    _lifetime
      ..applicationStarted.register((state) => _onStarted())
      ..applicationStopping.register((state) => _onStopping())
      ..applicationStopped.register((state) => _onStopped())
      ..applicationPaused.add(_onPaused)
      ..applicationResumed.add(_onResumed)
      ..applicationInactive.add(_onInactive)
      ..applicationDetached.add(_onDetached);
  }

  Widget app;

  FlutterLifetimeOptions? options;

  FlutterHostingEnvironment environment;

  @override
  Future<void> waitForStart(CancellationToken cancellationToken) async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = _handleFlutterError;

    PlatformDispatcher.instance.onError = _handleError;

    _lifetime.applicationStarted.register(
      (_) => runApp(
        FlutterLifecycleObserver(
          lifetime: _lifetime,
          child: app,
        ),
      ),
    );
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) {
    throw UnimplementedError();
  }

  /// Handles errors caught by the Flutter framework.
  ///
  /// Forwards the error to the [handleError] handler when in release mode and
  /// prints it to the console otherwise.
  void _handleFlutterError(FlutterErrorDetails details) {
    if (options?.flutterErrorHandler != null) {
      options?.flutterErrorHandler!(details);
    }
  }

  /// Prints the [error] and shows a dialog asking to send the error report.
  ///
  /// Additional device diagnostic data will be sent along the error if the
  /// user consents for it.
  bool _handleError(Object error, StackTrace stackTrace) {
    if (options?.errorHandler != null) {
      return options!.errorHandler!(error, stackTrace);
    }
    return false;
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
    _logger.logInformation('Application is inactive.');
  }

  void _onDetached() {
    _logger.logInformation('Application is detached.');
  }
}

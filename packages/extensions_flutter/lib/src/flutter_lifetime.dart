import 'dart:async';
import 'dart:ui';

import 'package:extensions/common.dart';
import 'package:extensions/hosting.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_application_wrapper.dart';
import 'flutter_error_handler.dart';
import 'flutter_lifecycle_observer.dart';

class FlutterLifetime extends HostLifetime {
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
  )   : _application = application,
        _errorHandler = errorHandler,
        _environment = environment,
        _applicationLifetime =
            applicationLifetime as FlutterApplicationLifetime,
        _logger = loggerFactory.createLogger('Hosting.Lifetime');

  HostEnvironment get environment => _environment;

  FlutterApplicationLifetime get applicationLifetime => _applicationLifetime;

  @override
  Future<void> waitForStart(CancellationToken cancellationToken) async {
    applicationLifetime
      ..applicationStarted.register(
        (state) => (state as FlutterLifetime)._onApplicationStarted(),
        this,
      )
      ..applicationStopping.register(
        (state) => (state as FlutterLifetime)._onApplicationStopping(),
        this,
      )
      ..applicationPaused.add(_onPaused)
      ..applicationResumed.add(_onResumed)
      ..applicationInactive.add(_onInactive)
      ..applicationDetached.add(_onDetached);

    applicationLifetime.applicationStarted.register(
      (_) {
        WidgetsFlutterBinding.ensureInitialized();

        FlutterError.onError = _errorHandler.onFlutterError;
        PlatformDispatcher.instance.onError = _errorHandler.onError;

        final app = FlutterLifecycleObserver(
          lifetime: applicationLifetime,
          child: _application.child,
        );

        runApp(app);
      },
    );
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) async =>
      applicationLifetime.stopApplication();

  void _onApplicationStarted() => _logger
    ..logInformation('Application started.')
    ..logInformation('Hosting environment: ${environment.environmentName}');

  void _onApplicationStopping() =>
      _logger.logInformation('Application is shutting down...');

  void _onPaused() => _logger.logInformation('Application paused.');

  void _onResumed() => _logger.logInformation('Application resumed.');

  void _onInactive() => _logger.logInformation('Application is inactive.');

  void _onDetached() => _logger.logInformation('Application is detached.');
}

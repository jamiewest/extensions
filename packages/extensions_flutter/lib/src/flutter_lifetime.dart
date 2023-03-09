import 'dart:async';
import 'dart:ui';

import 'package:extensions/hosting.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_builder_extensions.dart';
import 'flutter_error_handler.dart';

class FlutterLifetime<TApp extends Widget> extends HostLifetime {
  final TApp _application;
  final ErrorHandler _errorHandler;
  final Iterable<FlutterAppBuilder> _builders;
  final ServiceProvider _services;
  final HostEnvironment _environment;
  final FlutterApplicationLifetime _applicationLifetime;
  final Logger _logger;

  FlutterLifetime(
    TApp application,
    ErrorHandler errorHandler,
    Iterable<FlutterAppBuilder> builders,
    ServiceProvider services,
    HostEnvironment environment,
    HostApplicationLifetime applicationLifetime,
    LoggerFactory loggerFactory,
  )   : _application = application,
        _errorHandler = errorHandler,
        _builders = builders,
        _services = services,
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

        Widget? widget;
        for (var builder in _builders) {
          widget ??= _application;
          widget = builder(_services, widget);
        }

        runApp(widget!);
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

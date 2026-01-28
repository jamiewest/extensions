import 'dart:async';
import 'dart:ui';

import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:extensions/options.dart';
import 'package:extensions/system.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_error_handler.dart';
import 'flutter_lifetime_options.dart';

class FlutterLifetime implements HostLifetime {
  final Widget _application;
  final ErrorHandler _errorHandler;
  final HostEnvironment _environment;
  final FlutterApplicationLifetime _applicationLifetime;
  final FlutterLifetimeOptions _options;
  final Logger _logger;

  FlutterLifetime(
    Widget application,
    ErrorHandler errorHandler,
    HostEnvironment environment,
    HostApplicationLifetime applicationLifetime,
    Options<FlutterLifetimeOptions> options,
    LoggerFactory loggerFactory,
  ) : _application = application,
      _errorHandler = errorHandler,
      _environment = environment,
      _applicationLifetime = applicationLifetime as FlutterApplicationLifetime,
      _options = options.value!,
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

        runApp(_application);
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

  void _onApplicationStarted() {
    if (_options.suppressStatusMessages) return;
    _logger
      ..logInformation('Application started.')
      ..logInformation('Hosting environment: ${environment.environmentName}');
  }

  void _onApplicationStopping() {
    if (_options.suppressStatusMessages) return;
    _logger.logInformation('Application is shutting down...');
  }

  void _onPaused() {
    if (_options.suppressStatusMessages) return;
    _logger.logTrace('Application paused.');
  }

  void _onResumed() {
    if (_options.suppressStatusMessages) return;
    _logger.logTrace('Application resumed.');
  }

  void _onInactive() {
    if (_options.suppressStatusMessages) return;
    _logger.logTrace('Application is inactive.');
  }

  void _onHidden() {
    if (_options.suppressStatusMessages) return;
    _logger.logTrace('Application is hidden.');
  }

  void _onDetached() {
    if (_options.suppressStatusMessages) return;
    _logger.logTrace('Application is detached.');
  }
}

import 'dart:async';
import 'dart:ui';

import 'package:extensions/hosting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_lifecycle_observer.dart';
import 'flutter_lifetime_options.dart';

class FlutterLifetime extends HostLifetime {
  final FlutterLifetimeOptions _options;
  final HostEnvironment _environment;
  final FlutterApplicationLifetime _applicationLifetime;
  final Logger _logger;

  FlutterLifetime(
    Options<FlutterLifetimeOptions> options,
    HostEnvironment environment,
    HostApplicationLifetime applicationLifetime,
    LoggerFactory loggerFactory,
  )   : _options = options.value!,
        _environment = environment,
        _applicationLifetime =
            applicationLifetime as FlutterApplicationLifetime,
        _logger = loggerFactory.createLogger('Hosting.Lifetime');

  FlutterLifetimeOptions get options => _options;

  HostEnvironment get environment => _environment;

  FlutterApplicationLifetime get applicationLifetime => _applicationLifetime;

  @override
  Future<void> waitForStart(CancellationToken cancellationToken) async {
    if (!_options.suppressStatusMessages) {
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
    }

    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = _handleFlutterError;

    PlatformDispatcher.instance.onError = _handleError;

    applicationLifetime.applicationStarted.register(
      (_) => runApp(
        FlutterLifecycleObserver(
          lifetime: applicationLifetime,
          child: options.application!,
        ),
      ),
    );
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) async {
    applicationLifetime.stopApplication();
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  /// Handles errors caught by the Flutter framework.
  ///
  /// Forwards the error to the [_handleError] handler when in release mode and
  /// prints it to the console otherwise.
  void _handleFlutterError(FlutterErrorDetails details) {
    if (options.flutterErrorHandler != null) {
      options.flutterErrorHandler!(details);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  }

  /// Prints the [error] and shows a dialog asking to send the error report.
  ///
  /// Additional device diagnostic data will be sent along the error if the
  /// user consents for it.
  bool _handleError(Object error, StackTrace stackTrace) {
    if (options.errorHandler != null) {
      return options.errorHandler!(error, stackTrace);
    } else {
      //_logger.logError(message)
    }

    return false;
  }

  void _onApplicationStarted() {
    _logger
      ..logInformation('Application started.')
      ..logInformation('Hosting environment: ${environment.environmentName}');
  }

  void _onApplicationStopping() {
    _logger.logInformation('Application is shutting down...');
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

import 'dart:async';

import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:extensions_flutter_firebase/extensions_flutter_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

class FirebaseLifetime extends FlutterLifetime {
  final Logger _logger;
  FirebaseCrashlytics? _crashlytics;
  final FirebaseOptions _options;
  final ServiceProvider _services;

  FirebaseLifetime({
    required super.app,
    required ServiceProvider services,
    required Logger logger,
    required HostApplicationLifetime lifetime,
    required FirebaseOptions options,
    required super.environment,
  })  : _logger = logger,
        _options = options,
        _services = services,
        super(
          logger: logger,
          lifetime: lifetime,
        );

  @override
  Future<void> waitForStart(CancellationToken cancellationToken) async {
    WidgetsFlutterBinding.ensureInitialized();
    _logger.logTrace('Initializing Firebase.');
    await Firebase.initializeApp(
      options: _options,
    );

    _crashlytics = _services.getRequiredService<FirebaseCrashlytics>();

    FlutterError.onError = handleFlutterError;

    final analytics = _services.getRequiredService<FirebaseAnalytics>();

    await super.waitForStart(cancellationToken);

    analytics.logAppOpen();
  }

  /// Handles errors caught by the Flutter framework.
  ///
  /// Forwards the error to the [_handleError] handler when in release mode and
  /// prints it to the console otherwise.
  Future<void> handleFlutterError(FlutterErrorDetails details) async {
    if (environment.isProduction()) {
      await _crashlytics!.recordFlutterFatalError(details);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  }

  /// Prints the [error] and shows a dialog asking to send the error report.
  ///
  /// Additional device diagnostic data will be sent along the error if the
  /// user consents for it.
  Future<void> handleError(Object error, StackTrace stackTrace) async {
    _logger.logError('error: ', exception: Exception());

    if (environment.isProduction()) {
      await _crashlytics!.recordError(
        error,
        stackTrace,
        fatal: true,
      );
    }
  }
}

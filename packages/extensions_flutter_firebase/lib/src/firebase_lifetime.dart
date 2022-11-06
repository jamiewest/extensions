import 'dart:async';

import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:extensions_flutter_firebase/extensions_flutter_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

class FirebaseLifetime extends FlutterLifetime {
  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;
  final FirebaseOptions _firebaseOptions;

  FirebaseLifetime(
    super.options,
    super.environment,
    super.applicationLifetime,
    super.loggerFactory,
    FirebaseAnalytics analytics,
    FirebaseCrashlytics crashlytics,
    FirebaseOptions firebaseOptions,
  )   : _analytics = analytics,
        _crashlytics = crashlytics,
        _firebaseOptions = firebaseOptions;

  FirebaseAnalytics get analytics => _analytics;

  FirebaseCrashlytics get crashlytics => _crashlytics;

  FirebaseOptions get firebaseOptions => _firebaseOptions;

  @override
  Future<void> waitForStart(CancellationToken cancellationToken) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: _firebaseOptions,
    );

    FlutterError.onError = handleFlutterError;

    await super.waitForStart(cancellationToken);

    analytics.logAppOpen();
  }

  /// Handles errors caught by the Flutter framework.
  ///
  /// Forwards the error to the [_handleError] handler when in release mode and
  /// prints it to the console otherwise.
  Future<void> handleFlutterError(FlutterErrorDetails details) async {
    if (environment.isProduction()) {
      await _crashlytics.recordFlutterFatalError(details);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  }

  /// Prints the [error] and shows a dialog asking to send the error report.
  ///
  /// Additional device diagnostic data will be sent along the error if the
  /// user consents for it.
  Future<void> handleError(Object error, StackTrace stackTrace) async {
    //_logger.logError('error: ', exception: Exception());

    if (environment.isProduction()) {
      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: true,
      );
    }
  }
}

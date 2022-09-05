import 'dart:async';

import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

class FirebaseLifetime extends FlutterLifetime {
  final Logger _logger;
  final FlutterApplicationLifetime _lifetime;
  FirebaseCrashlytics? _crashlytics;
  final FirebaseOptions _options;

  FirebaseLifetime({
    required super.app,
    required Logger logger,
    required HostApplicationLifetime lifetime,
    required FirebaseOptions options,
    required super.environment,
  })  : _logger = logger,
        _options = options,
        _lifetime = lifetime as FlutterApplicationLifetime,
        super(
          logger: logger,
          lifetime: lifetime,
        );

  @override
  Future<void> waitForStart(CancellationToken cancellationToken) async {
    await Firebase.initializeApp(
      options: _options,
    );

    _crashlytics = FirebaseCrashlytics.instance;

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

  /// Handles errors caught by the Flutter framework.
  ///
  /// Forwards the error to the [_handleError] handler when in release mode and
  /// prints it to the console otherwise.
  Future<void> _handleFlutterError(FlutterErrorDetails details) async {
    if (environment.isProduction()) {
      await _crashlytics!.recordFlutterError(details);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  }

  /// Prints the [error] and shows a dialog asking to send the error report.
  ///
  /// Additional device diagnostic data will be sent along the error if the
  /// user consents for it.
  Future<void> _handleError(Object error, StackTrace stackTrace) async {
    _logger.logError('error: ', exception: Exception());

    if (environment.isProduction()) {
      await _crashlytics!.recordError(error, stackTrace);
    }
  }
}

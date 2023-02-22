import 'package:flutter/widgets.dart';

typedef ErrorHandler = bool Function(Object error, StackTrace stackTrace);
typedef FlutterErrorHandler = void Function(FlutterErrorDetails details);

/// Options for configuring Flutter at runtime.
class FlutterLifetimeOptions {
  /// Prints the [onError] and shows a dialog asking to send the error report.
  ///
  /// Additional device diagnostic data will be sent along the error if the
  /// user consents for it.
  ErrorHandler? onError;

  /// Handles errors caught by the Flutter framework.
  ///
  /// Forwards the error to the [onFlutterError] handler when in release mode
  /// and prints it to the console otherwise.
  FlutterErrorHandler? onFlutterError;

  /// Indicates if host lifetime status messages should be
  /// supressed such as on startup.
  ///
  /// The default is `false`.
  bool suppressStatusMessages = false;
}

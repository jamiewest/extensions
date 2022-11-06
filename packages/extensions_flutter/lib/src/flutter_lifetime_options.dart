import 'package:flutter/widgets.dart';

typedef FlutterErrorHandler = void Function(
  FlutterErrorDetails details,
);

typedef ErrorHandler = bool Function(
  Object error,
  StackTrace stackTrace,
);

/// Options for configuring Flutter at runtime.
class FlutterLifetimeOptions {
  Widget? application;

  /// Handles errors caught by the Flutter framework.
  FlutterErrorHandler? flutterErrorHandler;

  /// Handles unhandled asynchronous errors.
  ErrorHandler? errorHandler;

  /// Indicates if host lifetime status messages should be
  /// supressed such as on startup.
  ///
  /// The default is `false`.
  bool suppressStatusMessages = false;
}

import 'package:flutter/foundation.dart';

typedef FlutterErrorHandler = Future<void> Function(
  FlutterErrorDetails details,
);

typedef ErrorHandler = Future<void> Function(
  Object error,
  StackTrace stackTrace,
);

/// Options for configuring Flutter at runtime.
class FlutterLifetimeOptions {
  FlutterLifetimeOptions({
    this.flutterErrorHandler,
    this.errorHandler,
  });

  /// Handles errors caught by the Flutter framework.
  FlutterErrorHandler? flutterErrorHandler;

  /// Handles unhandled asynchronous errors.
  ErrorHandler? errorHandler;
}

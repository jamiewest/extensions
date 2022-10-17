import 'package:flutter/foundation.dart';

typedef FlutterErrorHandler = void Function(
  FlutterErrorDetails details,
);

typedef ErrorHandler = bool Function(
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

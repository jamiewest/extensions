import 'dart:ui';

import 'package:extensions/logging.dart';
import 'package:flutter/foundation.dart';

abstract class ErrorHandler {
  ErrorCallback? onError;
  FlutterExceptionHandler? onFlutterError;
}

class FlutterErrorHandler implements ErrorHandler {
  FlutterErrorHandler(Logger logger) {
    onError = (exception, stackTrace) {
      logger.logError('', error: exception);
      return true;
    };

    onFlutterError = (details) {
      logger.logError(details.exceptionAsString());
    };
  }

  @override
  ErrorCallback? onError;

  @override
  FlutterExceptionHandler? onFlutterError;
}

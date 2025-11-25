import 'dart:ui';

import 'package:extensions/logging.dart';
import 'package:flutter/foundation.dart';

abstract class ErrorHandler {
  ErrorCallback? onError;
  FlutterExceptionHandler? onFlutterError;
}

class FlutterErrorHandler implements ErrorHandler {
  FlutterErrorHandler(Logger logger)
      : _logger = logger,
        _previousPlatformOnError = PlatformDispatcher.instance.onError,
        _previousFlutterOnError = FlutterError.onError {
    onError = (exception, stackTrace) {
      _logPlatformError(exception, stackTrace);

      try {
        final handledByPrevious =
            _previousPlatformOnError?.call(exception, stackTrace);
        return handledByPrevious ?? false;
      } catch (callbackError, callbackStack) {
        _logger.logError(
          'Previous PlatformDispatcher.onError threw.',
          error: callbackError,
        );
        _logger.logError('Original stack trace:\n$stackTrace');
        _logger.logError('Callback stack trace:\n$callbackStack');
        return false;
      }
    };

    onFlutterError = (details) {
      _logFlutterError(details);

      try {
        final previous = _previousFlutterOnError;
        if (previous != null) {
          previous(details);
        } else {
          FlutterError.presentError(details);
        }
      } catch (callbackError, callbackStack) {
        _logger.logError(
          'Previous FlutterError.onError threw.',
          error: callbackError,
        );
        _logger.logError('Callback stack trace:\n$callbackStack');
        FlutterError.presentError(details);
      }
    };
  }

  final Logger _logger;

  final ErrorCallback? _previousPlatformOnError;

  final FlutterExceptionHandler? _previousFlutterOnError;

  @override
  ErrorCallback? onError;

  @override
  FlutterExceptionHandler? onFlutterError;

  void _logPlatformError(Object exception, StackTrace stackTrace) {
    _logger.logCritical(
      'Unhandled platform error: $exception\nStack trace:\n$stackTrace',
      error: exception,
    );
  }

  void _logFlutterError(FlutterErrorDetails details) {
    final buffer = StringBuffer('Unhandled Flutter error');

    final library = details.library;
    if (library != null && library.isNotEmpty) {
      buffer.write(' ($library)');
    }

    buffer.write(': ${details.exceptionAsString()}');

    final context = details.context;
    if (context != null) {
      buffer.write('\nContext: $context');
    }

    final stackTrace = details.stack;
    buffer.write(
      '\nStack trace:\n${stackTrace ?? 'No stack trace available.'}',
    );

    _logger.logCritical(buffer.toString(), error: details.exception);
  }
}

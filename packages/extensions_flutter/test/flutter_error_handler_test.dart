import 'dart:ui';

import 'package:extensions/logging.dart';
import 'package:extensions/system.dart';
import 'package:extensions_flutter/src/flutter_error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestLogEntry {
  _TestLogEntry(this.level, this.message, this.error);

  final LogLevel level;
  final String message;
  final Object? error;
}

class _TestLogger implements Logger {
  final entries = <_TestLogEntry>[];

  @override
  Disposable beginScope<TState>(TState state) => NullScope.instance;

  @override
  bool isEnabled(LogLevel logLevel) => true;

  @override
  void log<TState>({
    required LogLevel logLevel,
    required EventId eventId,
    required TState state,
    Object? error,
    required LogFormatter<TState> formatter,
  }) {
    entries.add(
      _TestLogEntry(
        logLevel,
        formatter(state, error),
        error,
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ErrorCallback? initialPlatformOnError;
  late FlutterExceptionHandler? initialFlutterOnError;

  setUp(() {
    initialPlatformOnError = PlatformDispatcher.instance.onError;
    initialFlutterOnError = FlutterError.onError;
  });

  tearDown(() {
    PlatformDispatcher.instance.onError = initialPlatformOnError;
    FlutterError.onError = initialFlutterOnError;
  });

  test('logs and delegates platform errors', () {
    var previousCalled = false;
    PlatformDispatcher.instance.onError = (exception, stackTrace) {
      previousCalled = true;
      return true;
    };

    final logger = _TestLogger();
    final handler = FlutterErrorHandler(logger);

    final exception = Exception('boom');
    final stack = StackTrace.current;

    final handled = handler.onError!(exception, stack);

    expect(handled, isTrue);
    expect(previousCalled, isTrue);
    expect(logger.entries, hasLength(1));

    final entry = logger.entries.first;
    expect(entry.message, contains('Unhandled platform error'));
    expect(entry.message, contains('boom'));
    expect(entry.message, contains('Stack trace'));
    expect(entry.error, same(exception));
    expect(entry.level, LogLevel.critical);
  });

  test('logs and returns false when previous platform handler throws', () {
    PlatformDispatcher.instance.onError = (exception, stackTrace) {
      throw StateError('fail');
    };

    final logger = _TestLogger();
    final handler = FlutterErrorHandler(logger);

    final exception = Exception('boom');
    final stack = StackTrace.current;

    final handled = handler.onError!(exception, stack);

    expect(handled, isFalse);
    expect(logger.entries.length, 4);
    expect(
      logger.entries.first.message,
      contains('Unhandled platform error'),
    );
    expect(
      logger.entries.any(
        (entry) =>
            entry.message.contains('Previous PlatformDispatcher.onError threw.'),
      ),
      isTrue,
    );
    expect(
      logger.entries.any(
        (entry) => entry.message.contains('Original stack trace:'),
      ),
      isTrue,
    );
    expect(
      logger.entries.any(
        (entry) => entry.message.contains('Callback stack trace:'),
      ),
      isTrue,
    );
  });

  test('logs flutter errors and calls previous handler', () {
    var previousCalled = false;
    FlutterError.onError = (details) {
      previousCalled = true;
    };

    final logger = _TestLogger();
    final handler = FlutterErrorHandler(logger);

    final exception = Exception('flutter boom');
    final stack = StackTrace.current;

    final details = FlutterErrorDetails(
      exception: exception,
      stack: stack,
      library: 'testLib',
      context: ErrorDescription('during test'),
    );

    handler.onFlutterError!(details);

    expect(previousCalled, isTrue);
    expect(logger.entries, hasLength(1));

    final entry = logger.entries.first;
    expect(entry.message, contains('Unhandled Flutter error'));
    expect(entry.message, contains('testLib'));
    expect(entry.message, contains('Context: during test'));
    expect(entry.message, contains('Stack trace'));
    expect(entry.error, same(exception));
    expect(entry.level, LogLevel.critical);
  });
}

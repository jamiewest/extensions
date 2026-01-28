import 'package:extensions/logging.dart';
import 'package:extensions/system.dart';
import 'package:extensions_flutter/src/flutter_application_lifetime.dart';
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
  group('FlutterApplicationLifetime', () {
    late _TestLogger logger;
    late FlutterApplicationLifetime lifetime;

    setUp(() {
      logger = _TestLogger();
      lifetime = FlutterApplicationLifetime(logger);
    });

    group('notifyPaused', () {
      test('executes registered handlers', () {
        var called = false;
        lifetime.applicationPaused.add(() => called = true);

        lifetime.notifyPaused();

        expect(called, isTrue);
      });

      test('executes handlers in reverse order', () {
        final order = <int>[];
        lifetime.applicationPaused.add(() => order.add(1));
        lifetime.applicationPaused.add(() => order.add(2));
        lifetime.applicationPaused.add(() => order.add(3));

        lifetime.notifyPaused();

        expect(order, [3, 2, 1]);
      });

      test('logs critical error when handler throws', () {
        lifetime.applicationPaused.add(() => throw Exception('handler error'));

        lifetime.notifyPaused();

        expect(logger.entries, hasLength(1));
        final entry = logger.entries.first;
        expect(entry.level, LogLevel.critical);
        expect(entry.message, contains('An error occurred pausing'));
      });
    });

    group('notifyResumed', () {
      test('executes registered handlers', () {
        var called = false;
        lifetime.applicationResumed.add(() => called = true);

        lifetime.notifyResumed();

        expect(called, isTrue);
      });

      test('executes handlers in reverse order', () {
        final order = <int>[];
        lifetime.applicationResumed.add(() => order.add(1));
        lifetime.applicationResumed.add(() => order.add(2));
        lifetime.applicationResumed.add(() => order.add(3));

        lifetime.notifyResumed();

        expect(order, [3, 2, 1]);
      });

      test('logs critical error when handler throws', () {
        lifetime.applicationResumed.add(() => throw Exception('handler error'));

        lifetime.notifyResumed();

        expect(logger.entries, hasLength(1));
        final entry = logger.entries.first;
        expect(entry.level, LogLevel.critical);
        expect(entry.message, contains('An error occurred resuming'));
      });
    });

    group('notifyInactive', () {
      test('executes registered handlers', () {
        var called = false;
        lifetime.applicationInactive.add(() => called = true);

        lifetime.notifyInactive();

        expect(called, isTrue);
      });

      test('executes handlers in reverse order', () {
        final order = <int>[];
        lifetime.applicationInactive.add(() => order.add(1));
        lifetime.applicationInactive.add(() => order.add(2));
        lifetime.applicationInactive.add(() => order.add(3));

        lifetime.notifyInactive();

        expect(order, [3, 2, 1]);
      });

      test('logs critical error when handler throws', () {
        lifetime.applicationInactive
            .add(() => throw Exception('handler error'));

        lifetime.notifyInactive();

        expect(logger.entries, hasLength(1));
        final entry = logger.entries.first;
        expect(entry.level, LogLevel.critical);
        expect(entry.message, contains('An error occurred while the application was inactive'));
      });
    });

    group('notifyDetached', () {
      test('executes registered handlers', () {
        var called = false;
        lifetime.applicationDetached.add(() => called = true);

        lifetime.notifyDetached();

        expect(called, isTrue);
      });

      test('executes handlers in reverse order', () {
        final order = <int>[];
        lifetime.applicationDetached.add(() => order.add(1));
        lifetime.applicationDetached.add(() => order.add(2));
        lifetime.applicationDetached.add(() => order.add(3));

        lifetime.notifyDetached();

        expect(order, [3, 2, 1]);
      });

      test('logs critical error when handler throws', () {
        lifetime.applicationDetached
            .add(() => throw Exception('handler error'));

        lifetime.notifyDetached();

        expect(logger.entries, hasLength(1));
        final entry = logger.entries.first;
        expect(entry.level, LogLevel.critical);
        expect(entry.message, contains('An error occurred detaching'));
      });
    });

    group('notifyHidden', () {
      test('executes registered handlers', () {
        var called = false;
        lifetime.applicationHidden.add(() => called = true);

        lifetime.notifyHidden();

        expect(called, isTrue);
      });

      test('executes handlers in reverse order', () {
        final order = <int>[];
        lifetime.applicationHidden.add(() => order.add(1));
        lifetime.applicationHidden.add(() => order.add(2));
        lifetime.applicationHidden.add(() => order.add(3));

        lifetime.notifyHidden();

        expect(order, [3, 2, 1]);
      });

      test('logs critical error when handler throws', () {
        lifetime.applicationHidden.add(() => throw Exception('handler error'));

        lifetime.notifyHidden();

        expect(logger.entries, hasLength(1));
        final entry = logger.entries.first;
        expect(entry.level, LogLevel.critical);
        expect(entry.message, contains('An error occurred hiding'));
      });
    });

    test('multiple handlers can be registered for the same event', () {
      var count = 0;
      lifetime.applicationPaused.add(() => count++);
      lifetime.applicationPaused.add(() => count++);
      lifetime.applicationPaused.add(() => count++);

      lifetime.notifyPaused();

      expect(count, 3);
    });

    test('handlers can be removed', () {
      var called = false;
      void handler() => called = true;

      lifetime.applicationPaused.add(handler);
      lifetime.applicationPaused.remove(handler);

      lifetime.notifyPaused();

      expect(called, isFalse);
    });
  });
}

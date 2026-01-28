import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestLogEntry {
  _TestLogEntry(this.level, this.message, this.category);

  final LogLevel level;
  final String message;
  final String category;
}

class _TestLogger implements Logger {
  _TestLogger([this.category = 'test']);

  final String category;
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
        category,
      ),
    );
  }
}

class _TestLoggerFactory implements LoggerFactory {
  final loggers = <String, _TestLogger>{};

  @override
  void addProvider(LoggerProvider provider) {}

  @override
  Logger createLogger(String categoryName) {
    return loggers.putIfAbsent(categoryName, () => _TestLogger(categoryName));
  }

  @override
  void dispose() {}
}

class _TestHostEnvironment implements HostEnvironment {
  @override
  String applicationName = 'test-app';

  @override
  String contentRootPath = '/tmp';

  @override
  FileProvider? contentRootFileProvider;

  @override
  String environmentName = 'test';
}

class _TestOptions implements Options<FlutterLifetimeOptions> {
  _TestOptions(this._options);
  final FlutterLifetimeOptions _options;

  @override
  FlutterLifetimeOptions? get value => _options;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterLifetime', () {
    late _TestLoggerFactory loggerFactory;
    late _TestLogger appLifetimeLogger;
    late FlutterApplicationLifetime applicationLifetime;
    late _TestHostEnvironment environment;
    late FlutterErrorHandler errorHandler;
    late Widget testWidget;

    setUp(() {
      loggerFactory = _TestLoggerFactory();
      appLifetimeLogger = _TestLogger('ApplicationLifetime');
      applicationLifetime = FlutterApplicationLifetime(appLifetimeLogger);
      environment = _TestHostEnvironment();
      errorHandler = FlutterErrorHandler(_TestLogger('ErrorHandler'));
      testWidget = const SizedBox();
    });

    FlutterLifetime createLifetime({bool suppressStatusMessages = false}) {
      return FlutterLifetime(
        testWidget,
        errorHandler,
        environment,
        applicationLifetime,
        _TestOptions(FlutterLifetimeOptions(suppressStatusMessages)),
        loggerFactory,
      );
    }

    test('creates logger with Hosting.Lifetime category', () {
      createLifetime();

      expect(loggerFactory.loggers, contains('Hosting.Lifetime'));
    });

    test('environment property returns the provided environment', () {
      final lifetime = createLifetime();

      expect(lifetime.environment, same(environment));
    });

    test('applicationLifetime property returns the provided lifetime', () {
      final lifetime = createLifetime();

      expect(lifetime.applicationLifetime, same(applicationLifetime));
    });

    test('stop calls stopApplication on applicationLifetime', () async {
      final lifetime = createLifetime();
      var stopCalled = false;

      applicationLifetime.applicationStopping.register((state) {
        stopCalled = true;
      });

      await lifetime.stop(CancellationToken());

      expect(stopCalled, isTrue);
    });

    test('waitForStart throws when cancellation already requested', () async {
      final lifetime = createLifetime();
      final cts = CancellationTokenSource()..cancel();

      expect(
        () => lifetime.waitForStart(cts.token),
        throwsA(isA<OperationCanceledException>()),
      );
    });

    test('waitForStart registers lifecycle handlers', () async {
      final lifetime = createLifetime();
      final cts = CancellationTokenSource();

      // Start waitForStart but don't await it - it will set up handlers
      // ignore: unawaited_futures
      lifetime.waitForStart(cts.token);

      // Verify handlers were registered
      expect(applicationLifetime.applicationPaused, isNotEmpty);
      expect(applicationLifetime.applicationResumed, isNotEmpty);
      expect(applicationLifetime.applicationInactive, isNotEmpty);
      expect(applicationLifetime.applicationHidden, isNotEmpty);
      expect(applicationLifetime.applicationDetached, isNotEmpty);

      // Clean up
      cts.cancel();
    });

    test('waitForStart removes handlers when cancelled', () async {
      final lifetime = createLifetime();
      final cts = CancellationTokenSource();

      // Start waitForStart
      // ignore: unawaited_futures
      lifetime.waitForStart(cts.token);

      // Handlers should be registered
      expect(applicationLifetime.applicationPaused, isNotEmpty);

      // Cancel to trigger cleanup
      cts.cancel();

      // Allow cancellation to process
      await Future<void>.delayed(Duration.zero);

      // Handlers should be removed
      expect(applicationLifetime.applicationPaused, isEmpty);
      expect(applicationLifetime.applicationResumed, isEmpty);
      expect(applicationLifetime.applicationInactive, isEmpty);
      expect(applicationLifetime.applicationHidden, isEmpty);
      expect(applicationLifetime.applicationDetached, isEmpty);
    });

    group('lifecycle logging', () {
      test('logs when application is stopping', () {
        final lifetime = createLifetime();
        final logger =
            loggerFactory.loggers['Hosting.Lifetime'] as _TestLogger;

        final cts = CancellationTokenSource();
        // ignore: unawaited_futures
        lifetime.waitForStart(cts.token);

        applicationLifetime.stopApplication();

        expect(
          logger.entries
              .any((e) => e.message.contains('Application is shutting down')),
          isTrue,
        );

        cts.cancel();
      });

      test('logs trace when paused', () {
        final lifetime = createLifetime();
        final logger =
            loggerFactory.loggers['Hosting.Lifetime'] as _TestLogger;

        final cts = CancellationTokenSource();
        // ignore: unawaited_futures
        lifetime.waitForStart(cts.token);

        applicationLifetime.notifyPaused();

        expect(
          logger.entries.any(
            (e) =>
                e.message.contains('Application paused') &&
                e.level == LogLevel.trace,
          ),
          isTrue,
        );

        cts.cancel();
      });

      test('logs trace when resumed', () {
        final lifetime = createLifetime();
        final logger =
            loggerFactory.loggers['Hosting.Lifetime'] as _TestLogger;

        final cts = CancellationTokenSource();
        // ignore: unawaited_futures
        lifetime.waitForStart(cts.token);

        applicationLifetime.notifyResumed();

        expect(
          logger.entries.any(
            (e) =>
                e.message.contains('Application resumed') &&
                e.level == LogLevel.trace,
          ),
          isTrue,
        );

        cts.cancel();
      });

      test('logs trace when inactive', () {
        final lifetime = createLifetime();
        final logger =
            loggerFactory.loggers['Hosting.Lifetime'] as _TestLogger;

        final cts = CancellationTokenSource();
        // ignore: unawaited_futures
        lifetime.waitForStart(cts.token);

        applicationLifetime.notifyInactive();

        expect(
          logger.entries.any(
            (e) =>
                e.message.contains('Application is inactive') &&
                e.level == LogLevel.trace,
          ),
          isTrue,
        );

        cts.cancel();
      });

      test('logs trace when hidden', () {
        final lifetime = createLifetime();
        final logger =
            loggerFactory.loggers['Hosting.Lifetime'] as _TestLogger;

        final cts = CancellationTokenSource();
        // ignore: unawaited_futures
        lifetime.waitForStart(cts.token);

        applicationLifetime.notifyHidden();

        expect(
          logger.entries.any(
            (e) =>
                e.message.contains('Application is hidden') &&
                e.level == LogLevel.trace,
          ),
          isTrue,
        );

        cts.cancel();
      });

      test('logs trace when detached', () {
        final lifetime = createLifetime();
        final logger =
            loggerFactory.loggers['Hosting.Lifetime'] as _TestLogger;

        final cts = CancellationTokenSource();
        // ignore: unawaited_futures
        lifetime.waitForStart(cts.token);

        applicationLifetime.notifyDetached();

        expect(
          logger.entries.any(
            (e) =>
                e.message.contains('Application is detached') &&
                e.level == LogLevel.trace,
          ),
          isTrue,
        );

        cts.cancel();
      });
    });

    group('suppressStatusMessages', () {
      test('suppresses stopping log when enabled', () {
        final lifetime = createLifetime(suppressStatusMessages: true);
        final logger =
            loggerFactory.loggers['Hosting.Lifetime'] as _TestLogger;

        final cts = CancellationTokenSource();
        // ignore: unawaited_futures
        lifetime.waitForStart(cts.token);

        applicationLifetime.stopApplication();

        expect(
          logger.entries
              .any((e) => e.message.contains('Application is shutting down')),
          isFalse,
        );

        cts.cancel();
      });

      test('suppresses lifecycle logs when enabled', () {
        final lifetime = createLifetime(suppressStatusMessages: true);
        final logger =
            loggerFactory.loggers['Hosting.Lifetime'] as _TestLogger;

        final cts = CancellationTokenSource();
        // ignore: unawaited_futures
        lifetime.waitForStart(cts.token);

        applicationLifetime
          ..notifyPaused()
          ..notifyResumed()
          ..notifyInactive()
          ..notifyHidden()
          ..notifyDetached();

        expect(logger.entries, isEmpty);

        cts.cancel();
      });

      test('still executes other registered callbacks when suppressed', () {
        final lifetime = createLifetime(suppressStatusMessages: true);
        var callbackExecuted = false;

        applicationLifetime.applicationPaused.add(() {
          callbackExecuted = true;
        });

        final cts = CancellationTokenSource();
        // ignore: unawaited_futures
        lifetime.waitForStart(cts.token);

        applicationLifetime.notifyPaused();

        expect(callbackExecuted, isTrue);

        cts.cancel();
      });
    });
  });
}

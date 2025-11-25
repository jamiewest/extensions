import 'package:extensions/logging.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:test/test.dart';

import 'test_logger.dart';

void main() {
  group('Logger', () {
    group('Log Operations', () {
      test('Log_CallsProviderLogger', () {
        final provider = TestLoggerProvider();
        final factory = LoggerFactory([provider]);
        final logger = factory.createLogger('TestCategory');

        logger.logInformation('Test message');

        final testLogger = provider.loggers['TestCategory'] as TestLogger;
        expect(testLogger.loggedMessages, hasLength(1));
        expect(testLogger.loggedMessages[0].message, 'Test message');
        expect(testLogger.loggedMessages[0].logLevel, LogLevel.information);
      });

      test('Log_WithError_IncludesErrorInEntry', () {
        final provider = FilterableLoggerProvider();
        final factory = LoggerFactory([provider]);
        final logger = factory.createLogger('TestCategory');

        final error = Exception('Test error');
        logger.logError('Error occurred', error: error);

        final testLogger = provider.loggers['TestCategory']!;
        expect(testLogger.loggedMessages, hasLength(1));
        expect(testLogger.loggedMessages[0].error, equals(error));
      });

      test('Log_WithEventId_IncludesEventIdInEntry', () {
        final provider = FilterableLoggerProvider();
        final factory = LoggerFactory([provider]);
        final logger = factory.createLogger('TestCategory');

        const eventId = EventId(100, 'TestEvent');
        logger.logInformation('Test message', eventId: eventId);

        final testLogger = provider.loggers['TestCategory']!;
        expect(testLogger.loggedMessages, hasLength(1));
        expect(testLogger.loggedMessages[0].eventId, equals(eventId));
      });

      test('Log_BelowMinLevel_DoesNotLog', () {
        final provider = FilterableLoggerProvider(LogLevel.warning);
        final factory = LoggerFactory([provider]);
        final logger = factory.createLogger('TestCategory');

        logger.logDebug('Debug message');
        logger.logInformation('Info message');

        final testLogger = provider.loggers['TestCategory']!;
        expect(testLogger.loggedMessages, isEmpty);
      });

      test('Log_AtOrAboveMinLevel_Logs', () {
        final provider = FilterableLoggerProvider(LogLevel.warning);
        final factory = LoggerFactory([provider]);
        final logger = factory.createLogger('TestCategory');

        logger.logWarning('Warning message');
        logger.logError('Error message');
        logger.logCritical('Critical message');

        final testLogger = provider.loggers['TestCategory']!;
        expect(testLogger.loggedMessages, hasLength(3));
      });
    });

    group('Log Level Methods', () {
      late LoggerFactory factory;
      late FilterableLoggerProvider provider;
      late Logger logger;

      setUp(() {
        provider = FilterableLoggerProvider();
        factory = LoggerFactory([provider]);
        logger = factory.createLogger('TestCategory');
      });

      test('LogTrace_CreatesTraceEntry', () {
        logger.logTrace('Trace message');

        final testLogger = provider.loggers['TestCategory']!;
        expect(testLogger.loggedMessages, hasLength(1));
        expect(testLogger.loggedMessages[0].logLevel, LogLevel.trace);
      });

      test('LogDebug_CreatesDebugEntry', () {
        logger.logDebug('Debug message');

        final testLogger = provider.loggers['TestCategory']!;
        expect(testLogger.loggedMessages, hasLength(1));
        expect(testLogger.loggedMessages[0].logLevel, LogLevel.debug);
      });

      test('LogInformation_CreatesInformationEntry', () {
        logger.logInformation('Info message');

        final testLogger = provider.loggers['TestCategory']!;
        expect(testLogger.loggedMessages, hasLength(1));
        expect(testLogger.loggedMessages[0].logLevel, LogLevel.information);
      });

      test('LogWarning_CreatesWarningEntry', () {
        logger.logWarning('Warning message');

        final testLogger = provider.loggers['TestCategory']!;
        expect(testLogger.loggedMessages, hasLength(1));
        expect(testLogger.loggedMessages[0].logLevel, LogLevel.warning);
      });

      test('LogError_CreatesErrorEntry', () {
        logger.logError('Error message');

        final testLogger = provider.loggers['TestCategory']!;
        expect(testLogger.loggedMessages, hasLength(1));
        expect(testLogger.loggedMessages[0].logLevel, LogLevel.error);
      });

      test('LogCritical_CreatesCriticalEntry', () {
        logger.logCritical('Critical message');

        final testLogger = provider.loggers['TestCategory']!;
        expect(testLogger.loggedMessages, hasLength(1));
        expect(testLogger.loggedMessages[0].logLevel, LogLevel.critical);
      });
    });

    group('IsEnabled', () {
      test('IsEnabled_ReturnsFalse_WhenBelowMinLevel', () {
        final provider = FilterableLoggerProvider(LogLevel.warning);
        final factory = LoggerFactory([provider]);
        final logger = factory.createLogger('TestCategory');

        expect(logger.isEnabled(LogLevel.trace), isFalse);
        expect(logger.isEnabled(LogLevel.debug), isFalse);
        expect(logger.isEnabled(LogLevel.information), isFalse);
      });

      test('IsEnabled_ReturnsTrue_WhenAtOrAboveMinLevel', () {
        final provider = FilterableLoggerProvider(LogLevel.warning);
        final factory = LoggerFactory([provider]);
        final logger = factory.createLogger('TestCategory');

        expect(logger.isEnabled(LogLevel.warning), isTrue);
        expect(logger.isEnabled(LogLevel.error), isTrue);
        expect(logger.isEnabled(LogLevel.critical), isTrue);
      });

      test('IsEnabled_ReturnsFalse_WhenNoProviders', () {
        final factory = LoggerFactory([]);
        final logger = factory.createLogger('TestCategory');

        for (final level in LogLevel.values) {
          expect(logger.isEnabled(level), isFalse);
        }
      });

      test('IsEnabled_ReturnsTrue_WhenAnyProviderEnabled', () {
        final provider1 = FilterableLoggerProvider(LogLevel.error);
        final provider2 = FilterableLoggerProvider(LogLevel.debug);
        final factory = LoggerFactory([provider1, provider2]);
        final logger = factory.createLogger('TestCategory');

        // Should return true if ANY provider is enabled
        expect(logger.isEnabled(LogLevel.debug), isTrue);
        expect(logger.isEnabled(LogLevel.warning), isTrue);
      });
    });

    group('Exception Handling', () {
      test('Log_SwallowsExceptionsFromProvider', () {
        final provider = ThrowingLoggerProvider(throwOnLog: true);
        final factory = LoggerFactory([provider]);
        final logger = factory.createLogger('TestCategory');

        // Should not throw
        expect(() => logger.logInformation('Test'), returnsNormally);
      });

      test('IsEnabled_SwallowsExceptionsFromProvider', () {
        final provider = ThrowingLoggerProvider(throwOnIsEnabled: true);
        final factory = LoggerFactory([provider]);
        final logger = factory.createLogger('TestCategory');

        // Should not throw and return false
        expect(logger.isEnabled(LogLevel.information), isFalse);
      });

      test('Log_ContinuesToOtherProviders_WhenOneThrows', () {
        final throwingProvider = ThrowingLoggerProvider(throwOnLog: true);
        final workingProvider = FilterableLoggerProvider();
        final factory = LoggerFactory([throwingProvider, workingProvider]);
        final logger = factory.createLogger('TestCategory');

        logger.logInformation('Test message');

        // Working provider should still receive the log
        final testLogger = workingProvider.loggers['TestCategory']!;
        expect(testLogger.loggedMessages, hasLength(1));
      });
    });

    group('Multiple Providers', () {
      test('Log_CallsAllProviders', () {
        final provider1 = FilterableLoggerProvider();
        final provider2 = FilterableLoggerProvider();
        final provider3 = FilterableLoggerProvider();
        final factory = LoggerFactory([provider1, provider2, provider3]);
        final logger = factory.createLogger('TestCategory');

        logger.logInformation('Test message');

        expect(
          provider1.loggers['TestCategory']!.loggedMessages,
          hasLength(1),
        );
        expect(
          provider2.loggers['TestCategory']!.loggedMessages,
          hasLength(1),
        );
        expect(
          provider3.loggers['TestCategory']!.loggedMessages,
          hasLength(1),
        );
      });

      test('Log_OnlyCallsEnabledProviders', () {
        final provider1 = FilterableLoggerProvider(LogLevel.error);
        final provider2 = FilterableLoggerProvider(LogLevel.debug);
        final factory = LoggerFactory([provider1, provider2]);
        final logger = factory.createLogger('TestCategory');

        logger.logInformation('Test message');

        // Only provider2 should log (provider1 requires Error or higher)
        expect(provider1.loggers['TestCategory']!.loggedMessages, isEmpty);
        expect(
          provider2.loggers['TestCategory']!.loggedMessages,
          hasLength(1),
        );
      });
    });

    group('Scopes', () {
      test('BeginScope_ReturnsDisposable', () {
        final provider = TestLoggerProvider();
        final factory = LoggerFactory([provider]);
        final logger = factory.createLogger('TestCategory');

        final scope = logger.beginScope('Test scope');

        expect(scope, isNotNull);
        expect(scope, isA<Disposable>());
      });

      test('BeginScope_AcceptsDifferentTypes', () {
        final provider = TestLoggerProvider();
        final factory = LoggerFactory([provider]);
        final logger = factory.createLogger('TestCategory');

        expect(() => logger.beginScope('String scope'), returnsNormally);
        expect(() => logger.beginScope(123), returnsNormally);
        expect(() => logger.beginScope({'key': 'value'}), returnsNormally);
      });
    });
  });
}

import 'package:extensions/logging.dart';

/// Marker type used for typed logger examples.
class UserService {}

/// Demonstrates advanced logging APIs such as typed loggers and `LoggerMessage`.
///
/// Run this file to see structured output for several advanced patterns.
void main() {
  print('=== Advanced Logging Features ===');

  print('\n--- Example 1: Typed Logger (Logger<T>) ---');
  final factory = LoggerFactory.create(
    (builder) => builder.addConsole(),
  );

  factory
      .createTypedLogger<UserService>()
      .logInformation('Typed logger for UserService created');

  print('\n--- Example 2: High-Performance LoggerMessage ---');

  // Cache delegates once and reuse them to avoid repeated allocations.
  final logUserLogin = LoggerMessage.define2<String, int>(
    LogLevel.information,
    const EventId(1, 'UserLogin'),
    'User {0} logged in from IP {1}',
  );

  final logProcessingTime = LoggerMessage.define1<int>(
    LogLevel.debug,
    const EventId(2, 'ProcessingTime'),
    'Request processed in {0}ms',
  );

  final logger = factory.createLogger('PerformanceDemo');
  logUserLogin(logger, 'john.doe', 192168001001, null);
  logProcessingTime(logger, 42, null);

  print('\n--- Example 3: Skip Enabled Check ---');

  final logCriticalError = LoggerMessage.define1<String>(
    LogLevel.critical,
    const EventId(3, 'CriticalError'),
    'Critical system error: {0}',
    options: LogDefineOptions(skipEnabledCheck: true),
  );

  logCriticalError(logger, 'Database connection failed', null);

  print('\n--- Example 4: Log Scopes ---');

  final defineUserScope = LoggerMessage.defineScope2<String, String>(
    'User: {0}, Session: {1}',
  );

  final scopedLogger = factory.createLogger('ScopedDemo');
  final scope = defineUserScope(scopedLogger, 'alice', 'sess-123');
  scopedLogger
    ..logInformation('Processing user request')
    ..logWarning('Rate limit approaching');
  scope?.dispose();

  print('\n--- Example 5: BufferedLogRecord Structure ---');

  final bufferedRecord = BufferedLogRecordImpl(
    timestamp: DateTime.now(),
    logLevel: LogLevel.information,
    eventId: const EventId(100, 'BatchLog'),
    formattedMessage: 'This is a buffered log entry',
    messageTemplate: 'This is a buffered log entry',
    attributes: [
      const MapEntry('UserId', '12345'),
      const MapEntry('Action', 'Purchase'),
      const MapEntry('Amount', 99.99),
    ],
  );

  print('Buffered Record:');
  print('  Timestamp: ${bufferedRecord.timestamp}');
  print('  Level: ${bufferedRecord.logLevel}');
  print('  Message: ${bufferedRecord.formattedMessage}');
  print('  Attributes: ${bufferedRecord.attributes.length}');

  print('\n--- Example 6: NullTypedLogger<T> ---');

  NullTypedLogger.instance<UserService>()
      .logInformation('This will not be logged');
  print('NullTypedLogger created (no output expected)');

  print('\n--- Example 7: Multiple Typed Loggers ---');

  final logger1 = factory.createTypedLogger<UserService>();
  final logger2 = factory.createTypedLogger<String>();

  logger1.logInformation('Message from UserService logger');
  logger2.logInformation('Message from String logger');

  // Cleanup
  factory.dispose();

  print('\n=== Advanced Logging Complete ===');
}

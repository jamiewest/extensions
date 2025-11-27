import 'package:extensions/logging.dart';

// Example class for typed logger demonstration
class UserService {}

void main() {
  print('=== Advanced Logging Features Demo ===\n');

  // Example 1: Typed Logger
  print('Example 1: Typed Logger (Logger<T>)');
  final factory = LoggerFactory.create(
    (builder) => builder.addConsole(),
  );

  factory.createTypedLogger<UserService>()
      .logInformation('Typed logger for UserService created');

  // Example 2: High-Performance LoggerMessage
  print('\nExample 2: High-Performance LoggerMessage');

  // Define reusable log message delegates
  final logUserLogin = LoggerMessage.define2<String, int>(
    LogLevel.information,
    EventId(1, 'UserLogin'),
    'User {0} logged in from IP {1}',
  );

  final logProcessingTime = LoggerMessage.define1<int>(
    LogLevel.debug,
    EventId(2, 'ProcessingTime'),
    'Request processed in {0}ms',
  );

  // Use the cached delegates (no allocations on subsequent calls)
  final logger = factory.createLogger('PerformanceDemo');
  logUserLogin(logger, 'john.doe', 192168001001, null);
  logProcessingTime(logger, 42, null);

  // Example 3: High-Performance LoggerMessage with SkipEnabledCheck
  print('\nExample 3: LoggerMessage with Skip Enabled Check');

  final logCriticalError = LoggerMessage.define1<String>(
    LogLevel.critical,
    EventId(3, 'CriticalError'),
    'Critical system error: {0}',
    options: LogDefineOptions(skipEnabledCheck: true),
  );

  logCriticalError(logger, 'Database connection failed', null);

  // Example 4: Log Scopes with LoggerMessage
  print('\nExample 4: Log Scopes with LoggerMessage');

  final defineUserScope = LoggerMessage.defineScope2<String, String>(
    'User: {0}, Session: {1}',
  );

  final scopedLogger = factory.createLogger('ScopedDemo');
  final scope = defineUserScope(scopedLogger, 'alice', 'sess-123');
  scopedLogger.logInformation('Processing user request');
  scopedLogger.logWarning('Rate limit approaching');
  scope?.dispose();

  // Example 5: BufferedLogRecord (data structure)
  print('\nExample 5: BufferedLogRecord Structure');

  final bufferedRecord = BufferedLogRecordImpl(
    timestamp: DateTime.now(),
    logLevel: LogLevel.information,
    eventId: EventId(100, 'BatchLog'),
    formattedMessage: 'This is a buffered log entry',
    messageTemplate: 'This is a buffered log entry',
    attributes: [
      MapEntry('UserId', '12345'),
      MapEntry('Action', 'Purchase'),
      MapEntry('Amount', 99.99),
    ],
  );

  print('Buffered Record:');
  print('  Timestamp: ${bufferedRecord.timestamp}');
  print('  Level: ${bufferedRecord.logLevel}');
  print('  Message: ${bufferedRecord.formattedMessage}');
  print('  Attributes: ${bufferedRecord.attributes.length}');

  // Example 6: NullTypedLogger
  print('\nExample 6: NullTypedLogger<T>');

  final nullLogger = NullTypedLogger.instance<UserService>();
  nullLogger.logInformation('This will not be logged');
  print('NullTypedLogger created (no output expected)');

  // Example 7: Multiple typed loggers
  print('\nExample 7: Multiple Typed Loggers');

  final logger1 = factory.createTypedLogger<UserService>();
  final logger2 = factory.createTypedLogger<String>();

  logger1.logInformation('Message from UserService logger');
  logger2.logInformation('Message from String logger');

  // Cleanup
  factory.dispose();

  print('\n=== Demo Complete ===');
}

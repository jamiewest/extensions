import 'package:extensions/logging.dart';

/// Demonstrates all available console formatters:
/// - Basic console logger (no colors)
/// - Simple console formatter (with colors and structured output)
/// - JSON console formatter (structured JSON logs)
/// - Systemd console formatter (systemd journal compatible)
void main() {
  print('=== Console Formatter Examples ===\n');

  // Example 1: Basic Console Logger
  print('--- Example 1: Basic Console Logger (No Colors) ---');
  final basicLogger = LoggerFactory.create(
    (builder) => builder
      ..addConsole()
      ..addFilter(level: LogLevel.trace),
  ).createLogger('BasicLogger');

  basicLogger
    ..logTrace('Trace message')
    ..logDebug('Debug message')
    ..logInformation('Information message')
    ..logWarning('Warning message')
    ..logError('Error message')
    ..logCritical('Critical message');

  print('\n--- Example 2: Simple Console Formatter (With Colors) ---');
  // Example 2: Simple Console Formatter with Colors
  final simpleLogger = LoggerFactory.create(
    (builder) => builder
      ..addSimpleConsole()
      ..addFilter(level: LogLevel.trace),
  ).createLogger('SimpleLogger');

  simpleLogger
    ..logTrace('Trace message with gray color')
    ..logDebug('Debug message with bright gray color')
    ..logInformation('Information message with bright white color')
    ..logWarning('Warning message with bright yellow color')
    ..logError('Error message with bright red color')
    ..logCritical('Critical message with bright red color');

  print('\n--- Example 3: Simple Console with Custom Options ---');
  // Example 3: Simple Console with Custom Options
  final customSimpleLogger = LoggerFactory.create(
    (builder) => builder
      ..addSimpleConsoleWithOptions((options) {
        options.colorBehavior = LoggerColorBehavior.enabled;
        options.timestampFormat = 'timestamp';
        options.singleLine = true; // Single line format
        options.includeScopes = false;
      })
      ..addFilter(level: LogLevel.information),
  ).createLogger('CustomSimple');

  customSimpleLogger
    ..logInformation('Single line format with timestamp')
    ..logWarning('Warnings are easier to spot with colors')
    ..logError('Errors stand out with bright red');

  print('\n--- Example 4: JSON Console Formatter ---');
  // Example 4: JSON Console Formatter
  final jsonLogger = LoggerFactory.create(
    (builder) => builder
      ..addJsonConsole()
      ..addFilter(level: LogLevel.debug),
  ).createLogger('JsonLogger');

  jsonLogger
    ..logDebug('Debug message in JSON format')
    ..logInformation('Information message in JSON format')
    ..logWarning('Warning message in JSON format')
    ..logError('Error message in JSON format');

  print('\n--- Example 5: JSON Console with Indentation ---');
  // Example 5: JSON Console with Pretty Printing
  final prettyJsonLogger = LoggerFactory.create(
    (builder) => builder
      ..addJsonConsoleWithOptions((options) {
        options.useJsonIndentation = true; // Pretty print JSON
        options.timestampFormat = 'timestamp';
        options.includeScopes = true;
      })
      ..addFilter(level: LogLevel.information),
  ).createLogger('PrettyJsonLogger');

  prettyJsonLogger
    ..logInformation('Pretty printed JSON log')
    ..logWarning('Warning with indented JSON')
    ..logError('Error with structured JSON output');

  print('\n--- Example 6: Systemd Console Formatter ---');
  // Example 6: Systemd Console Formatter
  final systemdLogger = LoggerFactory.create(
    (builder) => builder
      ..addSystemdConsole()
      ..addFilter(level: LogLevel.trace),
  ).createLogger('SystemdLogger');

  systemdLogger
    ..logTrace('Trace with priority 7')
    ..logDebug('Debug with priority 6')
    ..logInformation('Information with priority 5')
    ..logWarning('Warning with priority 4')
    ..logError('Error with priority 3')
    ..logCritical('Critical with priority 2');

  print('\n--- Example 7: Systemd with Timestamps ---');
  // Example 7: Systemd with Custom Options
  final customSystemdLogger = LoggerFactory.create(
    (builder) => builder
      ..addSystemdConsoleWithOptions((options) {
        options.timestampFormat = 'timestamp';
        options.includeScopes = true;
      })
      ..addFilter(level: LogLevel.information),
  ).createLogger('CustomSystemd');

  customSystemdLogger
    ..logInformation('Systemd log with timestamp')
    ..logWarning('Warning for systemd journal')
    ..logError('Error for systemd journal');

  print('\n--- Example 8: Logging with Event IDs ---');
  // Example 8: Structured Logging with Event IDs
  final eventLogger = LoggerFactory.create(
    (builder) => builder
      ..addSimpleConsole()
      ..addFilter(level: LogLevel.information),
  ).createLogger('EventLogger');

  eventLogger.log(
    logLevel: LogLevel.information,
    eventId: EventId(1001, 'UserLogin'),
    state: 'User successfully authenticated',
    formatter: (state, error) => state,
  );

  eventLogger.log(
    logLevel: LogLevel.warning,
    eventId: EventId(2001, 'HighMemoryUsage'),
    state: 'Memory usage exceeds 80%',
    formatter: (state, error) => state,
  );

  eventLogger.log(
    logLevel: LogLevel.error,
    eventId: EventId(3001, 'DatabaseConnection'),
    state: 'Failed to connect to database',
    error: Exception('Connection timeout after 30 seconds'),
    formatter: (state, error) => state,
  );

  print('\n=== All Examples Complete ===');
}

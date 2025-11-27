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
  LoggerFactory.create(
    (builder) => builder
      ..addConsole()
      ..addFilter(level: LogLevel.trace),
  ).createLogger('BasicLogger')
    ..logTrace('Trace message')
    ..logDebug('Debug message')
    ..logInformation('Information message')
    ..logWarning('Warning message')
    ..logError('Error message')
    ..logCritical('Critical message');

  print('\n--- Example 2: Simple Console Formatter (With Colors) ---');
  // Example 2: Simple Console Formatter with Colors
  LoggerFactory.create(
    (builder) => builder
      ..addSimpleConsole()
      ..addFilter(level: LogLevel.trace),
  ).createLogger('SimpleLogger')
    ..logTrace('Trace message with gray color')
    ..logDebug('Debug message with bright gray color')
    ..logInformation('Information message with bright white color')
    ..logWarning('Warning message with bright yellow color')
    ..logError('Error message with bright red color')
    ..logCritical('Critical message with bright red color');

  print('\n--- Example 3: Simple Console with Custom Options ---');
  // Example 3: Simple Console with Custom Options
  LoggerFactory.create(
    (builder) => builder
      ..addSimpleConsoleWithOptions((options) {
        options
          ..colorBehavior = LoggerColorBehavior.enabled
          ..timestampFormat = 'timestamp'
          ..singleLine = true // Single line format
          ..includeScopes = false;
      })
      ..addFilter(level: LogLevel.information),
  ).createLogger('CustomSimple')
    ..logInformation('Single line format with timestamp')
    ..logWarning('Warnings are easier to spot with colors')
    ..logError('Errors stand out with bright red');

  print('\n--- Example 4: JSON Console Formatter ---');
  // Example 4: JSON Console Formatter
  LoggerFactory.create(
    (builder) => builder
      ..addJsonConsole()
      ..addFilter(level: LogLevel.debug),
  ).createLogger('JsonLogger')
    ..logDebug('Debug message in JSON format')
    ..logInformation('Information message in JSON format')
    ..logWarning('Warning message in JSON format')
    ..logError('Error message in JSON format');

  print('\n--- Example 5: JSON Console with Indentation ---');
  // Example 5: JSON Console with Pretty Printing
  LoggerFactory.create(
    (builder) => builder
      ..addJsonConsoleWithOptions((options) {
        options
          ..useJsonIndentation = true // Pretty print JSON
          ..timestampFormat = 'timestamp'
          ..includeScopes = true;
      })
      ..addFilter(level: LogLevel.information),
  ).createLogger('PrettyJsonLogger')
    ..logInformation('Pretty printed JSON log')
    ..logWarning('Warning with indented JSON')
    ..logError('Error with structured JSON output');

  print('\n--- Example 6: Systemd Console Formatter ---');
  // Example 6: Systemd Console Formatter
  LoggerFactory.create(
    (builder) => builder
      ..addSystemdConsole()
      ..addFilter(level: LogLevel.trace),
  ).createLogger('SystemdLogger')
    ..logTrace('Trace with priority 7')
    ..logDebug('Debug with priority 6')
    ..logInformation('Information with priority 5')
    ..logWarning('Warning with priority 4')
    ..logError('Error with priority 3')
    ..logCritical('Critical with priority 2');

  print('\n--- Example 7: Systemd with Timestamps ---');
  // Example 7: Systemd with Custom Options
  LoggerFactory.create(
    (builder) => builder
      ..addSystemdConsoleWithOptions((options) {
        options
          ..timestampFormat = 'timestamp'
          ..includeScopes = true;
      })
      ..addFilter(level: LogLevel.information),
  ).createLogger('CustomSystemd')
    ..logInformation('Systemd log with timestamp')
    ..logWarning('Warning for systemd journal')
    ..logError('Error for systemd journal');

  print('\n--- Example 8: Logging with Event IDs ---');
  // Example 8: Structured Logging with Event IDs
  LoggerFactory.create(
    (builder) => builder
      ..addSimpleConsole()
      ..addFilter(level: LogLevel.information),
  ).createLogger('EventLogger')
    ..log(
      logLevel: LogLevel.information,
      eventId: const EventId(1001, 'UserLogin'),
      state: 'User successfully authenticated',
      formatter: (state, error) => state,
    )
    ..log(
      logLevel: LogLevel.warning,
      eventId: const EventId(2001, 'HighMemoryUsage'),
      state: 'Memory usage exceeds 80%',
      formatter: (state, error) => state,
    )
    ..log(
      logLevel: LogLevel.error,
      eventId: const EventId(3001, 'DatabaseConnection'),
      state: 'Failed to connect to database',
      error: Exception('Connection timeout after 30 seconds'),
      formatter: (state, error) => state,
    );

  print('\n=== All Examples Complete ===');
}

import 'package:extensions/logging.dart';

/// Demonstrates basic logger factory setup and level filtering.
///
/// Run this file to see only warning-and-above messages in console output.
void main() {
  print('=== Logging Example ===');
  print('--- Warning And Above Filter ---');

  // #region create_logger_factory
  final loggerFactory = LoggerFactory.create(
    (builder) => builder
      ..addSimpleConsole()
      // Use addConsole() for plain console formatting.
      ..addFilter(
        // Set to `LogLevel.trace` to see every log call below.
        level: LogLevel.warning,
      ),
  );
  final logger = loggerFactory.createLogger('MyLogger');
  // #endregion

  // #region log_at_levels
  logger
    ..logTrace('This is a trace message')
    ..logDebug('This is a debug message')
    ..logInformation('This is an information message')
    ..logWarning('This is a warning message')
    ..logError('This is an error message');
  // #endregion

  loggerFactory.dispose();
}

import 'package:extensions/logging.dart';

// Creates a [Logger] using the [LoggerFactory.create] static method
// using the provided `configure` function.
//
// Note: The debug logger uses dart:developer.log() which outputs to the
// debugger console, not stdout. To see output when running from command line,
// use addConsole() or addSimpleConsole() instead of addDebug().
void main() {
  LoggerFactory.create(
    (builder) => builder
      ..addSimpleConsole()
      //..addConsole() // Use console logger to see output in terminal
      ..addFilter(
        level: LogLevel.warning, // Set to trace to see all log levels
      ),
  ).createLogger('MyLogger')

    // Log at different levels to demonstrate the hierarchy
    ..logTrace('This is a trace message')
    ..logDebug('This is a debug message')
    ..logInformation('This is an information message')
    ..logWarning('This is a warning message')
    ..logError('This is an error message');
}

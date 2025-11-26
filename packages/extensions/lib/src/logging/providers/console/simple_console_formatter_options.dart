import 'console_formatter_options.dart';
import 'logger_color_behavior.dart';

/// Options for the built-in simple console log formatter.
class SimpleConsoleFormatterOptions extends ConsoleFormatterOptions {
  /// Creates a new instance of [SimpleConsoleFormatterOptions].
  SimpleConsoleFormatterOptions();

  /// Describes when to use color when logging messages.
  ///
  /// Defaults to [LoggerColorBehavior.defaultBehavior].
  LoggerColorBehavior colorBehavior = LoggerColorBehavior.defaultBehavior;

  /// Indicates whether the entire message is logged in a single line.
  ///
  /// Defaults to `false`.
  bool singleLine = false;
}

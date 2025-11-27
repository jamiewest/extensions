import 'console_formatter_options.dart';

/// Options for the built-in JSON console log formatter.
class JsonConsoleFormatterOptions extends ConsoleFormatterOptions {
  /// Creates a new instance of [JsonConsoleFormatterOptions].
  JsonConsoleFormatterOptions();

  /// Gets or sets the JSON writer options.
  ///
  /// When true, the JSON output will be indented for readability.
  /// Defaults to `false`.
  bool useJsonIndentation = false;
}

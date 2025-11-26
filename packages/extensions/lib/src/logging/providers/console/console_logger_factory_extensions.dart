import '../../../../dependency_injection.dart';
import '../../logger_factory.dart';
import '../../logger_provider.dart';
import '../../logging_builder.dart';
import 'console_logger_provider.dart';
import 'formatted_console_logger_provider.dart';
import 'simple_console_formatter.dart';
import 'simple_console_formatter_options.dart';

/// Extension methods for the [LoggerFactory] class.
extension ConsoleLoggerFactoryExtensions on LoggingBuilder {
  /// Adds a console logger to the logging builder.
  ///
  /// This logger writes messages to the console using a basic format.
  LoggingBuilder addConsole() {
    services.tryAddIterable(
      ServiceDescriptor.singleton<LoggerProvider>(
        (sp) => ConsoleLoggerProvider(),
      ),
    );
    return this;
  }

  /// Adds a simple console logger with default formatting options.
  ///
  /// The simple console formatter provides structured output with timestamps,
  /// log levels, categories, and exception details.
  LoggingBuilder addSimpleConsole() {
    final options = SimpleConsoleFormatterOptions();
    final formatter = SimpleConsoleFormatter(options);
    services.tryAddIterable(
      ServiceDescriptor.singleton<LoggerProvider>(
        (sp) => FormattedConsoleLoggerProvider(formatter),
      ),
    );
    return this;
  }

  /// Adds a simple console logger with custom formatting options.
  ///
  /// The [configure] callback allows customization of the formatter options.
  ///
  /// Example:
  /// ```dart
  /// builder.addSimpleConsoleWithOptions((options) {
  ///   options.singleLine = true;
  ///   options.timestampFormat = 'yyyy-MM-dd HH:mm:ss';
  ///   options.includeScopes = true;
  ///   options.colorBehavior = LoggerColorBehavior.enabled;
  /// });
  /// ```
  LoggingBuilder addSimpleConsoleWithOptions(
    void Function(SimpleConsoleFormatterOptions) configure,
  ) {
    final options = SimpleConsoleFormatterOptions();
    configure(options);
    final formatter = SimpleConsoleFormatter(options);
    services.tryAddIterable(
      ServiceDescriptor.singleton<LoggerProvider>(
        (sp) => FormattedConsoleLoggerProvider(formatter),
      ),
    );
    return this;
  }
}

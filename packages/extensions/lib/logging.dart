/// Provides a flexible logging infrastructure with support for multiple
/// log providers and structured logging.
///
/// This library implements a comprehensive logging system inspired by
/// Microsoft.Extensions.Logging, supporting various output formats and
/// log levels with dependency injection integration.
///
/// ## Basic Usage
///
/// Configure logging with dependency injection:
///
/// ```dart
/// final services = ServiceCollection()
///   ..addLogging((builder) {
///     builder
///       ..setMinimumLevel(LogLevel.debug)
///       ..addSimpleConsole()
///       ..addDebug();
///   });
///
/// final provider = services.buildServiceProvider();
/// final logger = provider.getRequiredService<ILogger>();
/// ```
///
/// ## Logging Messages
///
/// Log messages at different severity levels:
///
/// ```dart
/// logger.logInformation('Application started');
/// logger.logWarning('Low disk space');
/// logger.logError('Failed to connect', error: exception);
/// logger.logDebug('Cache hit for key: {Key}', ['user123']);
/// ```
///
/// ## Console Formatters
///
/// Multiple console output formats are available:
///
/// - **Simple**: Human-readable format with colors
/// - **JSON**: Structured JSON output for log aggregation
/// - **Systemd**: Systemd journal compatible format
///
/// ```dart
/// builder.addJsonConsole();  // JSON format
/// builder.addSystemdConsole();  // Systemd format
/// ```
///
/// ## Scoped Logging
///
/// Create log scopes for contextual information:
///
/// ```dart
/// using((scope) {
///   logger.logInformation('Processing order');
///   // All logs in this scope include the order ID
/// }, logger.beginScope({'OrderId': '12345'}));
/// ```
library;

export 'src/logging/buffered_log_record.dart';
export 'src/logging/buffered_logger.dart';
export 'src/logging/default_logger_level_configure_options.dart';
export 'src/logging/event_id.dart';
export 'src/logging/filter_logging_builder_extensions.dart';
export 'src/logging/i_logger_provider_configuration.dart';
export 'src/logging/i_logger_provider_configuration_factory.dart';
export 'src/logging/log_level.dart';
export 'src/logging/logger.dart';
export 'src/logging/logger_extensions.dart';
export 'src/logging/logger_factory.dart';
export 'src/logging/logger_factory_extensions.dart';
export 'src/logging/logger_factory_options.dart';
export 'src/logging/logger_filter_options.dart';
export 'src/logging/logger_filter_rule.dart';
export 'src/logging/logger_message.dart';
export 'src/logging/logger_provider.dart';
export 'src/logging/logger_provider_configuration_factory.dart';
export 'src/logging/logger_provider_configuration_impl.dart';
export 'src/logging/logging_builder.dart';
export 'src/logging/logging_builder_configuration_extensions.dart';
export 'src/logging/logging_builder_extensions.dart';
export 'src/logging/null_logger.dart';
export 'src/logging/null_logger_factory.dart';
export 'src/logging/null_scope.dart';
export 'src/logging/provider_alias_utilities.dart';
export 'src/logging/providers/configuration/logging_configuration.dart';
export 'src/logging/providers/console/console_formatter.dart';
export 'src/logging/providers/console/console_formatter_names.dart';
export 'src/logging/providers/console/console_formatter_options.dart';
export 'src/logging/providers/console/console_logger.dart';
export 'src/logging/providers/console/console_logger_factory_extensions.dart';
export 'src/logging/providers/console/console_logger_provider.dart';
export 'src/logging/providers/console/formatted_console_logger.dart';
export 'src/logging/providers/console/formatted_console_logger_provider.dart';
export 'src/logging/providers/console/json_console_formatter.dart';
export 'src/logging/providers/console/json_console_formatter_options.dart';
export 'src/logging/providers/console/log_entry.dart';
export 'src/logging/providers/console/logger_color_behavior.dart';
export 'src/logging/providers/console/simple_console_formatter.dart';
export 'src/logging/providers/console/simple_console_formatter_options.dart';
export 'src/logging/providers/console/systemd_console_formatter.dart';
export 'src/logging/providers/console/systemd_console_formatter_options.dart';
export 'src/logging/providers/debug/debug_logger.dart';
export 'src/logging/providers/debug/debug_logger_factory_extensions.dart';
export 'src/logging/providers/debug/debug_logger_provider.dart';
export 'src/logging/typed_logger.dart';

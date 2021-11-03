import '../../logging.dart';
import '../dependency_injection/service_collection.dart';
import '../options/options_service_collection_extensions.dart';
import 'logger_filter_options.dart';
import 'logger_filter_rule.dart';
import 'logger_information.dart';
import 'logging_builder.dart';

typedef CategoryLevelFilterAction = bool Function(
  String category,
  LogLevel level,
);

typedef LevelFilterAction = bool Function(LogLevel level);

typedef FilterAction = bool Function(
  String provider,
  String category,
  LogLevel level,
);

typedef ConfigureOptionsAction1 = void Function(LoggerFilterOptions options);

extension LoggerFilterOptionsExtensions on LoggerFilterOptions {
  /// Adds a log filter to the factory.
  LoggerFilterOptions addFilter({
    required MessageLoggerFilter levelFilter,
  }) {
    _addRule(
      filter: levelFilter,
    );
    return this;
  }

  void _addRule({
    required MessageLoggerFilter filter,
  }) {
    rules.add(
      LoggerFilterRule(
        null,
        null,
        null,
        filter,
      ),
    );
  }
}

/// Extension methods for setting up logging services in an [ServiceCollection].
extension FilterLoggingBuilderExtensions on LoggingBuilder {
  LoggingBuilder addFilter(MessageLoggerFilter filter) => _configureFilter(
        (options) => options.addFilter(
          levelFilter: filter,
        ),
      );

  LoggingBuilder _configureFilter(
    ConfigureOptionsAction1 configure,
  ) {
    services.configure<LoggerFilterOptions>(
      () => LoggerFilterOptions(),
      (options) => configure(options),
    );
    return this;
  }
}

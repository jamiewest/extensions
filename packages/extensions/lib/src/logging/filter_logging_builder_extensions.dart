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
  String category,
  LogLevel level,
);

typedef ConfigureOptionsAction = void Function(LoggerFilterOptions options);

extension LoggerFilterOptionsExtensions on LoggerFilterOptions {
  /// Adds a log filter to the factory.
  LoggerFilterOptions addFilter({
    String? category,
    LevelFilterAction? levelFilter,
  }) {
    _addRule(
      category: category!,
      filter: (name, category, level) => levelFilter!(level!),
    );
    return this;
  }

  void _addRule({
    required String category,
    LogLevel? level,
    required MessageLoggerFilter filter,
  }) {
    rules.add(
      LoggerFilterRule(
        'type',
        category,
        level,
        filter,
      ),
    );
  }
}

/// Extension methods for setting up logging services in an [ServiceCollection].
extension FilterLoggingBuilderExtensions on LoggingBuilder {
  LoggingBuilder addFilter(String category, FilterAction filter) =>
      configureFilter(
        (options) => options.addFilter(
          levelFilter: (level) => filter(category, level),
        ),
      );

  LoggingBuilder configureFilter(
    ConfigureOptionsAction configure,
  ) {
    services.configure<LoggerFilterOptions>(
      () => LoggerFilterOptions(),
      (options) => configure,
    );
    return this;
  }
}

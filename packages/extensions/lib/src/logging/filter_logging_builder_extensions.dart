import '../../logging.dart';
import '../dependency_injection/service_collection.dart';
import '../options/options_service_collection_extensions.dart';
import 'logger_information.dart';

typedef CategoryLevelFilterAction = bool Function(
  String? category,
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
    String? category,
    LogLevel? level,
    CategoryLevelFilterAction? categoryLevelFilter,
    LevelFilterAction? levelFilter,
    MessageLoggerFilter? filter,
  }) {
    if (category != null && level != null) {
      _addRule(
        category: category,
        level: level,
      );
    }

    if (level != null) {
      _addRule(level: level);
    }

    if (category != null && levelFilter != null) {
      _addRule(
        category: category,
        filter: (provider, category, level) => levelFilter(level!),
      );
    }

    if (levelFilter != null) {
      _addRule(
        filter: (provider, category, level) => levelFilter(level!),
      );
    }

    if (categoryLevelFilter != null) {
      _addRule(
        filter: (provider, category, level) => categoryLevelFilter(
          category,
          level!,
        ),
      );
    }

    if (filter != null) {
      _addRule(
        filter: filter,
      );
    }
    return this;
  }

  void _addRule({
    String? type,
    String? category,
    LogLevel? level,
    MessageLoggerFilter? filter,
  }) {
    rules.add(
      LoggerFilterRule(
        type,
        category,
        level,
        filter,
      ),
    );
  }
}

/// Extension methods for setting up logging services in an [ServiceCollection].
extension FilterLoggingBuilderExtensions on LoggingBuilder {
  LoggingBuilder addFilter({
    String? category,
    LogLevel? level,
    MessageLoggerFilter? filter,
    CategoryLevelFilterAction? categoryLevelFilter,
    LevelFilterAction? levelFilter,
  }) =>
      _configureFilter(
        (options) => options.addFilter(
          category: category,
          level: level,
          levelFilter: levelFilter,
          categoryLevelFilter: categoryLevelFilter,
          filter: filter,
        ),
      );

  LoggingBuilder _configureFilter(
    ConfigureOptionsAction1 configure,
  ) {
    services.configure<LoggerFilterOptions>(
      LoggerFilterOptions.new,
      (options) => configure(options),
    );
    return this;
  }
}

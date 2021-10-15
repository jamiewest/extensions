import '../../logging.dart';
import '../dependency_injection/service_collection.dart';
import 'logger_filter_options.dart';
import 'logger_filter_rule.dart';
import 'logging_builder.dart';
import '../options/options_service_collection_extensions.dart';

typedef CategoryLevelFilterAction = bool Function(
  String category,
  LogLevel level,
);

typedef LevelFilterAction = bool Function(LogLevel level);

typedef FilterAction = bool Function(
  String type,
  String category,
  LogLevel level,
);

typedef ConfigureOptionsAction = void Function(LoggerFilterOptions options);

/// Extension methods for setting up logging services in an [ServiceCollection].
extension FilterLoggingBuilderExtension on LoggingBuilder {
  /// Adds a log filter to the factory.
  LoggingBuilder addFilter({
    String? category,
    LogLevel? level,
  }) {
    return this;
  }

  // LoggingBuilder configureFilter(
  //   ConfigureOptionsAction configure,
  // ) {
  //   services.configure<LoggerFilterOptions>(
  //     () => LoggerFilterOptions(),
  //     (options) => options..
  //   );
  //   return this;
  // }

  LoggerFilterOptions _addRule(
    LoggerFilterOptions options,
    String type,
    String category,
    LogLevel? level,
    ConfigureFilter filter,
  ) {
    options.rules.add(
      LoggerFilterRule(
        type,
        category,
        level,
        filter,
      ),
    );
    return options;
  }
}

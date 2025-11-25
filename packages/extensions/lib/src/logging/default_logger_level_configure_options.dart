import '../options/configure_options.dart';
import 'log_level.dart';
import 'logger_filter_options.dart';

class DefaultLoggerLevelConfigureOptions
    extends ConfigureOptionsBase<LoggerFilterOptions> {
  DefaultLoggerLevelConfigureOptions(LogLevel level)
      : super(
          (options) => options.minLevel = level,
        );
}

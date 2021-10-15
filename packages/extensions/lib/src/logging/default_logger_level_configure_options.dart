import '../options/configure_options.dart';
import 'log_level.dart';
import 'logger_filter_options.dart';

class _DefaultLoggerLevelConfigureOptions
    extends ConfigureOptions<LoggerFilterOptions> {
  _DefaultLoggerLevelConfigureOptions(LogLevel level)
      : super((options) => options.minLevel = level);
}

import 'logger.dart';
import 'logger_provider.dart';
import 'null_logger.dart';

/// Provider for the [NullLogger].
class NullLoggerProvider implements LoggerProvider {
  const NullLoggerProvider();

  /// Returns an instance of [NullLoggerProvider].
  static NullLoggerProvider get instance => const NullLoggerProvider();

  @override
  Logger createLogger(String categoryName) => NullLogger.instance;

  @override
  void dispose() {}
}

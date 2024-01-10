import 'logger.dart';
import 'logger_factory.dart';
import 'logger_provider.dart';
import 'null_logger.dart';

/// An [LoggerFactory] used to create instance of
///[NullLogger] that logs nothing.
class NullLoggerFactory implements LoggerFactory {
  /// Creates a new [NullLoggerFactory] instance.
  const NullLoggerFactory();

  /// Returns the shared instance of [NullLoggerFactory].
  static const NullLoggerFactory instance = NullLoggerFactory();

  /// This returns a [NullLogger] instance which logs nothing.
  @override
  Logger createLogger(String categoryName) => NullLogger.instance;

  /// This method ignores the parameter and does nothing.
  @override
  void addProvider(LoggerProvider loggerProvider) {}

  @override
  void dispose() {}
}

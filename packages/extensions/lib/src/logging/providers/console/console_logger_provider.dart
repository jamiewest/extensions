import '../../../../logging.dart';

/// The provider for the [ConsoleLogger].
class ConsoleLoggerProvider implements LoggerProvider {
  @override
  Logger createLogger(String categoryName) => ConsoleLogger(categoryName);

  @override
  void dispose() {}
}

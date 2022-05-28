import '../../../../logging.dart';

import 'console_logger.dart';

/// The provider for the [ConsoleLogger].
class ConsoleLoggerProvider implements LoggerProvider {
  @override
  Logger createLogger(String categoryName) => ConsoleLogger(categoryName);

  @override
  void dispose() {}
}

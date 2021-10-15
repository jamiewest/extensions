import 'package:extensions/logging.dart';

import 'debug_logger.dart';

/// The provider for the [DebugLogger].
class DebugLoggerProvider implements LoggerProvider {
  @override
  Logger createLogger(String categoryName) => DebugLogger(categoryName);

  @override
  void dispose() {}
}

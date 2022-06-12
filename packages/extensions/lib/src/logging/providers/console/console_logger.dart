import '../../../../primitives.dart';
import '../../event_id.dart';
import '../../log_level.dart';

import '../../logger.dart';
import '../../null_scope.dart';

/// A logger that writes messages in the debug output window only when a
/// debugger is attached.
class ConsoleLogger implements Logger {
  final String loggerName;

  /// Initializes a new instance of the [ConsoleLogger] class.
  ConsoleLogger(String name) : loggerName = name;

  @override
  Disposable beginScope<TState>(TState state) => NullScope.instance;

  @override
  bool isEnabled(LogLevel logLevel) => logLevel != LogLevel.none;

  @override
  void log<TState>({
    required LogLevel logLevel,
    required EventId eventId,
    required TState state,
    Exception? exception,
    required LogFormatter<TState> formatter,
  }) {
    if (!isEnabled(logLevel)) {
      return;
    }

    var formattedMessage = formatter(state, exception);
    if (formattedMessage.isEmpty) {
      return;
    }

    var message = '${logLevel.name}: $formattedMessage';

    if (exception != null) {
      message = '$message\n\n$exception';
    }

    print(message);
  }
}

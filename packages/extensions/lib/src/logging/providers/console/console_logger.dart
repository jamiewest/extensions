import '../../../system/disposable.dart';
import '../../event_id.dart';
import '../../log_level.dart';

import '../../logger.dart';
import '../../null_scope.dart';

/// A logger that writes messages to the console output.
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
    Object? error,
    required LogFormatter<TState> formatter,
  }) {
    if (!isEnabled(logLevel)) {
      return;
    }

    var formattedMessage = formatter(state, error);
    if (formattedMessage.isEmpty) {
      return;
    }

    var message = '${logLevel.name}: $formattedMessage';

    if (error != null) {
      message = '$message\n\n$error';
    }

    print(message);
  }
}

import 'package:extensions/src/logging/null_scope.dart';

import '../../../shared/disposable.dart';
import '../../event_id.dart';
import '../../log_level.dart';
import '../../logger.dart';

/// A logger that writes messages in the debug output window only when a
/// debugger is attached.
class DebugLogger implements Logger {
  final String _name;

  DebugLogger(String name) : _name = name;

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
    required LogFormatter formatter,
  }) {
    if (!isEnabled(logLevel)) {
      return;
    }

    var message = formatter(state, exception);
    if (message.isEmpty) {
      return;
    }

    var m = '${logLevel.toString()}: $message';

    if (exception != null) {
      m = m + exception.toString();
    }

    print(m);
  }
}

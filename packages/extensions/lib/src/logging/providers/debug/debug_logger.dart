import 'dart:developer' as developer;

import '../../../system/disposable.dart';
import '../../event_id.dart';
import '../../log_level.dart';
import '../../logger.dart';
import '../../null_scope.dart';

/// A logger that writes messages in the debug output window only when a
/// debugger is attached.
class DebugLogger implements Logger {
  final String _name;

  /// Initializes a new instance of the [DebugLogger] class.
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

    developer.log(
      message,
      time: DateTime.now(),
      level: _getLogLevel(logLevel),
      name: _name,
      error: error,
    );
  }

  int _getLogLevel(LogLevel level) {
    var value = 0;
    switch (level) {
      case LogLevel.information:
        value = 800;
        break;
      case LogLevel.warning:
        value = 900;
        break;
      case LogLevel.critical:
        value = 1000;
        break;
      case LogLevel.debug:
        value = 500;
        break;
      case LogLevel.none:
        value = 2000;
        break;
      default:
    }

    return value;
  }
}

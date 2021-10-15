import 'dart:developer' as developer;

import '../../../shared/disposable.dart';
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

    // TODO: Capitalize the first letter after the period.
    // ex. LogLevel.information -> LogLevel.Information
    var message = '${logLevel.toString()}: $formattedMessage';

    if (exception != null) {
      message = '$message\n\n$exception';
    }

    developer.log(message, name: _name);
  }
}

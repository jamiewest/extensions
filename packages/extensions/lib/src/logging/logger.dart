import '../system/disposable.dart';
import 'event_id.dart';
import 'log_level.dart';

/// Function to create a `String` message of the `state` and `exception`.
typedef LogFormatter<TState> = String Function(
  TState state,
  Object? error,
);

/// Represents a type used to perform logging.
///
/// Aggregates most logging patterns to a single method.
abstract class Logger {
  /// Writes a log entry.
  void log<TState>({
    required LogLevel logLevel,
    required EventId eventId,
    required TState state,
    Object? error,
    required LogFormatter<TState> formatter,
  });

  /// Checks if the given [logLevel] is enabled.
  bool isEnabled(LogLevel logLevel);

  /// Begins a logical operation scope.
  Disposable? beginScope<TState>(TState state);
}

class Scope implements Disposable {
  @override
  void dispose() {}
}

import '../../event_id.dart';
import '../../log_level.dart';
import '../../logger.dart';

/// Holds information about a log entry.
class LogEntry<TState> {
  /// Creates a new instance of [LogEntry].
  LogEntry({
    required this.logLevel,
    required this.category,
    required this.eventId,
    required this.state,
    this.exception,
    required this.formatter,
  });

  /// The log level.
  final LogLevel logLevel;

  /// The category name for the logger.
  final String category;

  /// The event id.
  final EventId eventId;

  /// The state object.
  final TState state;

  /// The exception related to this entry, if any.
  final Object? exception;

  /// The formatter function.
  final LogFormatter<TState> formatter;
}

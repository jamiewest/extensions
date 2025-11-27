import 'event_id.dart';
import 'log_level.dart';

/// Represents a buffered log record to be written in batch to a buffered
/// logger.
abstract class BufferedLogRecord {
  /// Gets the time when the log record was first created.
  DateTime get timestamp;

  /// Gets the record's logging severity level.
  LogLevel get logLevel;

  /// Gets the record's event ID.
  EventId get eventId;

  /// Gets an exception string for this record.
  String? get exception;

  /// Gets an activity span ID for this record, representing the state of the
  /// thread that created the record.
  String? get activitySpanId;

  /// Gets an activity trace ID for this record, representing the state of the
  /// thread that created the record.
  String? get activityTraceId;

  /// Gets the formatted log message.
  String? get formattedMessage;

  /// Gets the original log message template.
  String? get messageTemplate;

  /// Gets the variable set of name/value pairs associated with the record.
  List<MapEntry<String, Object?>> get attributes;
}

/// Default implementation of [BufferedLogRecord].
class BufferedLogRecordImpl implements BufferedLogRecord {
  /// Creates a new instance of [BufferedLogRecordImpl].
  BufferedLogRecordImpl({
    required this.timestamp,
    required this.logLevel,
    required this.eventId,
    this.exception,
    this.activitySpanId,
    this.activityTraceId,
    this.formattedMessage,
    this.messageTemplate,
    List<MapEntry<String, Object?>>? attributes,
  }) : attributes = attributes ?? [];

  @override
  final DateTime timestamp;

  @override
  final LogLevel logLevel;

  @override
  final EventId eventId;

  @override
  final String? exception;

  @override
  final String? activitySpanId;

  @override
  final String? activityTraceId;

  @override
  final String? formattedMessage;

  @override
  final String? messageTemplate;

  @override
  final List<MapEntry<String, Object?>> attributes;
}

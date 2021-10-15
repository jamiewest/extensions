import 'event_id.dart';
import 'log_level.dart';
import 'logger.dart';

extension LoggerExtensions on Logger {
  /// Formats and writes a debug log message.
  void logDebug(
    String? message, {
    EventId? eventId,
    Exception? exception,
    List<Object>? args,
  }) =>
      log(
        logLevel: LogLevel.debug,
        eventId: eventId ?? EventId.empty(),
        exception: exception,
        state: message ?? '',
        formatter: (s, e) => s as String,
      );

  /// Formats and writes a trace log message.
  void logTrace(
    String? message, {
    EventId? eventId,
    Exception? exception,
  }) =>
      log<String>(
        logLevel: LogLevel.trace,
        eventId: eventId ?? EventId.empty(),
        exception: exception,
        state: message ?? '',
        formatter: (s, e) => s,
      );

  /// Formats and writes an informational log message.
  void logInformation(
    String? message, {
    EventId? eventId,
    Exception? exception,
  }) =>
      log<String>(
        logLevel: LogLevel.information,
        eventId: eventId ?? EventId.empty(),
        exception: exception,
        state: message ?? '',
        formatter: (s, e) => s,
      );

  /// Formats and writes a warning log message.
  void logWarning(
    String? message, {
    EventId? eventId,
    Exception? exception,
  }) =>
      log<String>(
        logLevel: LogLevel.warning,
        eventId: eventId ?? EventId.empty(),
        exception: exception,
        state: message ?? '',
        formatter: (s, e) => s,
      );

  /// Formats and writes an error log message.
  void logError(
    String? message, {
    EventId? eventId,
    required Exception exception,
  }) =>
      log<String>(
        logLevel: LogLevel.error,
        eventId: eventId ?? const EventId(0, null),
        exception: exception,
        state: message ?? '',
        formatter: (s, e) => s,
      );

  /// Formats and writes a critical log message.
  void logCritical(
    String? message, {
    EventId? eventId,
    Exception? exception,
    List<Object>? args,
  }) =>
      log<String>(
        logLevel: LogLevel.critical,
        eventId: eventId ?? const EventId(0, null),
        exception: exception,
        state: message ?? '',
        formatter: (s, e) => s,
      );

  // /// Formats the message and creates a scope.
  // static Disposable beginScope(
  //   String messageFormat,
  //   List<Object>? args,
  // ) =>
  //     beginScope(FormattedLogValues(messageFormat, args));

// static String _messageFormatter(FormattedLogValues state, Exception? error)=>
  //     state.toString();
}

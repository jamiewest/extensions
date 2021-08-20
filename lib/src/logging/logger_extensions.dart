// import 'event_id.dart';
// import 'log_level.dart';
// import 'logger.dart';

// extension LoggerExtensions on Logger {
//   /// Formats and writes a debug log message.
//   void logDebug(
//     String? message, {
//     EventId? eventId,
//     Exception? exception,
//   }) =>
//       log(
//         logLevel: LogLevel.debug,
//         eventId: eventId,
//         exception: exception,
//         state: message,
//       );

//   /// Formats and writes a trace log message.
//   void logTrace(
//     String? message, {
//     EventId? eventId,
//     Exception? exception,
//   }) =>
//       log(
//         logLevel: LogLevel.trace,
//         eventId: eventId,
//         exception: exception,
//         state: message,
//       );

//   /// Formats and writes an informational log message.
//   void logInformation(
//     String? message, {
//     EventId? eventId,
//     Exception? exception,
//   }) =>
//       log(
//         logLevel: LogLevel.information,
//         eventId: eventId,
//         exception: exception,
//         state: message,
//       );

//   /// Formats and writes a warning log message.
//   void logWarning(
//     String? message, {
//     EventId? eventId,
//     Exception? exception,
//   }) =>
//       log(
//         logLevel: LogLevel.warning,
//         eventId: eventId,
//         exception: exception,
//         state: message,
//       );

//   /// Formats and writes an error log message.
//   void logError(
//     String? message, {
//     EventId? eventId,
//     required Exception exception,
//   }) =>
//       log(
//         logLevel: LogLevel.error,
//         eventId: eventId,
//         exception: exception,
//         state: message,
//       );

//   /// Formats and writes a critical log message.
//   void logCritical(
//     String? message, {
//     EventId? eventId,
//     Exception? exception,
//   }) =>
//       log(
//         logLevel: LogLevel.critical,
//         eventId: eventId,
//         exception: exception,
//         state: message,
//       );
// }

import '../error_content.dart';
import 'realtime_server_message.dart';
import 'realtime_server_message_type.dart';

/// A server message indicating that an error occurred.
///
/// This is an experimental feature.
class ErrorRealtimeServerMessage extends RealtimeServerMessage {
  /// Creates a new [ErrorRealtimeServerMessage].
  ErrorRealtimeServerMessage() : super(RealtimeServerMessageType.error);

  /// The error content.
  ErrorContent? error;

  /// The ID of the message that originated the error.
  String? originatingMessageId;
}

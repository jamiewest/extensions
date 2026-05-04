import '../contents/error_content.dart';
import 'realtime_server_message.dart';
import 'realtime_server_message_type.dart';

/// Represents a real-time server error message.
///
/// Remarks: Used with the [Error].
class ErrorRealtimeServerMessage extends RealtimeServerMessage {
  /// Initializes a new instance of the [ErrorRealtimeServerMessage] class.
  ErrorRealtimeServerMessage() {
    Type = RealtimeServerMessageType.error;
  }

  /// Gets or sets the error content associated with the error message.
  ErrorContent? error;

  /// Gets or sets the ID of the client message that caused the error.
  ///
  /// Remarks: Unlike [MessageId], which identifies this server message itself,
  /// this property identifies the originating client message that triggered the
  /// error.
  String? originatingMessageId;
}

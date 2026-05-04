import 'realtime_server_message_type.dart';

/// Represents a real-time server response message.
class RealtimeServerMessage {
  RealtimeServerMessage();

  /// Gets or sets the type of the real-time response.
  RealtimeServerMessageType type;

  /// Gets or sets the optional message ID associated with the response. This
  /// can be used for tracking and correlation purposes.
  String? messageId;

  /// Gets or sets the raw representation of the response. This can be used to
  /// hold the original data structure received from the model.
  ///
  /// Remarks: The raw representation is typically used for custom or
  /// unsupported message types. For example, the model may accept a JSON
  /// serialized server message.
  Object? rawRepresentation;
}

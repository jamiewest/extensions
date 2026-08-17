import 'realtime_server_message_type.dart';

/// Represents a real-time server response message.
///
/// This is an experimental feature.
class RealtimeServerMessage {
  /// Creates a new [RealtimeServerMessage] with the given [type].
  RealtimeServerMessage(this.type);

  /// The type of the real-time response.
  RealtimeServerMessageType type;

  /// The optional message ID associated with the response.
  ///
  /// This can be used for tracking and correlation purposes.
  String? messageId;

  /// The raw representation of the response.
  ///
  /// This can be used to hold the original data structure received from the
  /// model.
  Object? rawRepresentation;
}

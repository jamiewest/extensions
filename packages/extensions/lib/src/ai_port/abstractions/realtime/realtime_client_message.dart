/// Represents a real-time message the client sends to the model.
class RealtimeClientMessage {
  RealtimeClientMessage();

  /// Gets or sets the optional message ID associated with the message. This can
  /// be used for tracking and correlation purposes.
  String? messageId;

  /// Gets or sets the raw representation of the message. This can be used to
  /// send the raw data to the model.
  ///
  /// Remarks: The raw representation is typically used for custom or
  /// unsupported message types. For example, the model may accept a JSON
  /// serialized message.
  Object? rawRepresentation;
}

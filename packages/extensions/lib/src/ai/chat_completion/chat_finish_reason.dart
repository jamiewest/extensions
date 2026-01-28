/// Represents the reason a chat response finished being generated.
class ChatFinishReason {
  /// Creates a new [ChatFinishReason] with the given [value].
  const ChatFinishReason(this.value);

  /// The reason value.
  final String value;

  /// The model finished generating naturally (e.g. end of turn).
  static const ChatFinishReason stop = ChatFinishReason('stop');

  /// The model reached the maximum output token limit.
  static const ChatFinishReason length = ChatFinishReason('length');

  /// The model is requesting tool calls to be made.
  static const ChatFinishReason toolCalls = ChatFinishReason('tool_calls');

  /// The response was filtered by a content filter.
  static const ChatFinishReason contentFilter =
      ChatFinishReason('content_filter');

  @override
  bool operator ==(Object other) =>
      other is ChatFinishReason &&
      value.toLowerCase() == other.value.toLowerCase();

  @override
  int get hashCode => value.toLowerCase().hashCode;

  @override
  String toString() => value;
}

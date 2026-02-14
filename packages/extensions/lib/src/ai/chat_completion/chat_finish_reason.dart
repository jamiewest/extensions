import 'package:extensions/annotations.dart';

/// Represents the reason a chat response finished being generated.
@Source(
  name: 'ChatFinishReason.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/ChatCompletion/',
  commit: 'c378af04f386f8c6b1980c47822b1ca0ac7bf639',
)
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

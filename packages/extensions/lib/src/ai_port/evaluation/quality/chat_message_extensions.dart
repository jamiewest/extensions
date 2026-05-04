import '../../abstractions/chat_completion/chat_message.dart';

extension ChatMessageExtensions on Iterable<ChatMessage> {
  String renderAsJson({JsonSerializerOptions? options}) {
    _ = Throw.ifNull(messages);
    var messagesJsonArray = jsonArray();
    for (final message in messages) {
      var messageJsonNode = JsonSerializer.serializeToNode(
        message,
        AIJsonUtilities.defaultOptions.getTypeInfo(typeof(ChatMessage)),
      );
      if (messageJsonNode != null) {
        messagesJsonArray.add(messageJsonNode);
      }
    }
    var renderedMessages = messagesJsonArray.toJsonString(options);
    return renderedMessages;
  }
}

import '../../abstractions/chat_completion/chat_message.dart';

extension ChatMessageExtensions on ChatMessage {
  bool containsImageWithSupportedFormat({Iterable<ChatMessage>? conversation}) {
    return message.contents.any((c) => c.isImageWithSupportedFormat());
  }
}

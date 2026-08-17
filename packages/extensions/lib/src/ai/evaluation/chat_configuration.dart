import '../chat_completion/chat_client.dart';

/// Specifies the [ChatClient] to use when evaluation is performed by an AI
/// model.
class ChatConfiguration {
  /// Creates a [ChatConfiguration] wrapping [chatClient].
  const ChatConfiguration(this.chatClient);

  /// The [ChatClient] used to communicate with an AI model during evaluation.
  final ChatClient chatClient;
}

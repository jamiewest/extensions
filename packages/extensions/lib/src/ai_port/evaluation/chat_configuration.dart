import '../abstractions/chat_completion/chat_client.dart';

/// Specifies the [ChatClient] that should be used when evaluation is
/// performed using an AI model.
///
/// [chatClient] An [ChatClient] that can be used to communicate with an AI
/// model.
class ChatConfiguration {
  /// Specifies the [ChatClient] that should be used when evaluation is
  /// performed using an AI model.
  ///
  /// [chatClient] An [ChatClient] that can be used to communicate with an AI
  /// model.
  const ChatConfiguration(ChatClient chatClient) : chatClient = chatClient;

  /// Gets an [ChatClient] that can be used to communicate with an AI model.
  final ChatClient chatClient = chatClient;
}

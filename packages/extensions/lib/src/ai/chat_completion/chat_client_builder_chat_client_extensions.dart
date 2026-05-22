import 'chat_client.dart';
import 'chat_client_builder.dart';

/// Provides extension methods for working with [ChatClient] in the context
/// of [ChatClientBuilder]
extension ChatClientBuilderChatClientExtensions on ChatClient {
  /// Creates a new [ChatClientBuilder] using `innerClient` as its inner client.
  ChatClientBuilder asBuilder() => ChatClientBuilder(this);
}

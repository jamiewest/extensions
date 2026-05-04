import '../abstractions/chat_completion/chat_client.dart';
import 'chat_client_builder.dart';

/// Provides extension methods for working with [ChatClient] in the context of
/// [ChatClientBuilder].
extension ChatClientBuilderChatClientExtensions on ChatClient {
  /// Creates a new [ChatClientBuilder] using `innerClient` as its inner client.
  ///
  /// Remarks: This method is equivalent to using the [ChatClientBuilder]
  /// constructor directly, specifying `innerClient` as the inner client.
  ///
  /// Returns: The new [ChatClientBuilder] instance.
  ///
  /// [innerClient] The client to use as the inner client.
  ChatClientBuilder asBuilder() {
    _ = Throw.ifNull(innerClient);
    return chatClientBuilder(innerClient);
  }
}

import '../../system/threading/cancellation_token.dart';
import 'chat_client.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response.dart';
import 'chat_response_update.dart';

/// A [ChatClient] that delegates all calls to an inner client.
///
/// Subclass this to create middleware that wraps specific methods
/// while delegating others.
abstract class DelegatingChatClient implements ChatClient {
  /// Creates a new [DelegatingChatClient] wrapping [innerClient].
  DelegatingChatClient(this.innerClient);

  /// The inner client to delegate to.
  final ChatClient innerClient;

  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.getChatResponse(
        messages: messages,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  Stream<ChatResponseUpdate> getStreamingChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.getStreamingChatResponse(
        messages: messages,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  T? getService<T>({Object? key}) => innerClient.getService<T>(key: key);

  @override
  void dispose() => innerClient.dispose();
}

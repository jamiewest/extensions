import '../../system/threading/cancellation_token.dart';
import 'chat_client.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response.dart';
import 'chat_response_update.dart';

/// Provides an optional base class for an [ChatClient] that passes through
/// calls to another instance.
///
/// This is recommended as a base type when building clients that can be chained
/// around an underlying [ChatClient]. The default implementation simply passes
/// each call to the inner client instance.
abstract class DelegatingChatClient implements ChatClient {
  /// Initializes a new instance of the [DelegatingChatClient] class.
  DelegatingChatClient(this.innerClient);

  /// The inner client to delegate to.
  final ChatClient innerClient;

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.getResponse(
        messages: messages,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.getStreamingResponse(
        messages: messages,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  T? getService<T>({Object? key}) => innerClient.getService<T>(key: key);

  @override
  void dispose() => innerClient.dispose();
}

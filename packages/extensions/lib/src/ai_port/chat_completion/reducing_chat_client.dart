import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/chat_completion/chat_response_update.dart';
import '../abstractions/chat_completion/delegating_chat_client.dart';
import '../abstractions/chat_reduction/chat_reducer.dart';

/// A chat client that reduces the size of a message list.
class ReducingChatClient extends DelegatingChatClient {
  /// Initializes a new instance of the [ReducingChatClient] class.
  ///
  /// [innerClient] The underlying [ChatClient], or the next instance in a chain
  /// of clients.
  ///
  /// [reducer] The reducer to be used by this instance.
  const ReducingChatClient(ChatClient innerClient, ChatReducer reducer)
    : _reducer = Throw.ifNull(reducer);

  final ChatReducer _reducer;

  @override
  Future<ChatResponse> getResponse(
    Iterable<ChatMessage> messages, {
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    messages = await _reducer
        .reduceAsync(messages, cancellationToken)
        .configureAwait(false);
    return await base
        .getResponseAsync(messages, options, cancellationToken)
        .configureAwait(false);
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages, {
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    messages = await _reducer
        .reduceAsync(messages, cancellationToken)
        .configureAwait(false);
    for (final update
        in base
            .getStreamingResponseAsync(messages, options, cancellationToken)
            .configureAwait(false)) {
      yield update;
    }
  }
}

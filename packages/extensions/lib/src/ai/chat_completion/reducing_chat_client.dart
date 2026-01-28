import 'dart:async';

import '../../system/threading/cancellation_token.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_reducer.dart';
import 'chat_response.dart';
import 'chat_response_update.dart';
import 'delegating_chat_client.dart';

/// A [DelegatingChatClient] that reduces chat messages before forwarding
/// requests to the inner client.
///
/// This is useful for managing context window limits by summarizing or
/// trimming message history.
class ReducingChatClient extends DelegatingChatClient {
  /// Creates a new [ReducingChatClient].
  ///
  /// [innerClient] is the underlying client to delegate to.
  /// [reducer] is the [ChatReducer] used to reduce messages.
  ReducingChatClient(
    super.innerClient, {
    required this.reducer,
  });

  /// The reducer used to reduce messages before forwarding.
  final ChatReducer reducer;

  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final reduced = await reducer.reduce(
      messages.toList(),
      cancellationToken: cancellationToken,
    );
    return super.getChatResponse(
      messages: reduced,
      options: options,
      cancellationToken: cancellationToken,
    );
  }

  @override
  Stream<ChatResponseUpdate> getStreamingChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    Stream<ChatResponseUpdate> stream() async* {
      final reduced = await reducer.reduce(
        messages.toList(),
        cancellationToken: cancellationToken,
      );
      yield* super.getStreamingChatResponse(
        messages: reduced,
        options: options,
        cancellationToken: cancellationToken,
      );
    }

    return stream();
  }
}

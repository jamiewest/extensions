import 'dart:async';

import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import 'chat_client.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response.dart';
import 'chat_response_update.dart';
import 'delegating_chat_client.dart';

/// A function that handles a chat response request.
typedef ChatClientResponseHandler = Future<ChatResponse> Function(
  Iterable<ChatMessage> messages,
  ChatOptions? options,
  ChatClient innerClient,
  CancellationToken? cancellationToken,
);

/// A function that handles a streaming chat response request.
typedef ChatClientStreamingResponseHandler = Stream<ChatResponseUpdate>
    Function(
  Iterable<ChatMessage> messages,
  ChatOptions? options,
  ChatClient innerClient,
  CancellationToken? cancellationToken,
);

/// A [DelegatingChatClient] that uses anonymous delegates to implement
/// its functionality.
///
/// This makes it easy to create custom middleware without subclassing
/// [DelegatingChatClient].
@Source(
  name: 'AnonymousDelegatingChatClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/ChatCompletion/',
  commit: 'b56aec451afe841d1865da4c9cb45fd5a379a519',
)
class AnonymousDelegatingChatClient extends DelegatingChatClient {
  /// Creates a new [AnonymousDelegatingChatClient].
  ///
  /// [innerClient] is the underlying client to delegate to.
  /// [responseHandler] optionally overrides [getChatResponse].
  /// [streamingResponseHandler] optionally overrides
  /// [getStreamingChatResponse].
  AnonymousDelegatingChatClient(
    super.innerClient, {
    this.responseHandler,
    this.streamingResponseHandler,
  });

  /// The handler for non-streaming responses.
  final ChatClientResponseHandler? responseHandler;

  /// The handler for streaming responses.
  final ChatClientStreamingResponseHandler? streamingResponseHandler;

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    if (responseHandler != null) {
      return responseHandler!(
        messages,
        options,
        innerClient,
        cancellationToken,
      );
    }
    return super.getResponse(
      messages: messages,
      options: options,
      cancellationToken: cancellationToken,
    );
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    if (streamingResponseHandler != null) {
      return streamingResponseHandler!(
        messages,
        options,
        innerClient,
        cancellationToken,
      );
    }
    return super.getStreamingResponse(
      messages: messages,
      options: options,
      cancellationToken: cancellationToken,
    );
  }
}

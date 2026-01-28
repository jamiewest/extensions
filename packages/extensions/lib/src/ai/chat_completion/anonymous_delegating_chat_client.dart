import 'dart:async';

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
typedef ChatClientStreamingResponseHandler
    = Stream<ChatResponseUpdate> Function(
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
  Future<ChatResponse> getChatResponse({
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
    return super.getChatResponse(
      messages: messages,
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
    if (streamingResponseHandler != null) {
      return streamingResponseHandler!(
        messages,
        options,
        innerClient,
        cancellationToken,
      );
    }
    return super.getStreamingChatResponse(
      messages: messages,
      options: options,
      cancellationToken: cancellationToken,
    );
  }
}

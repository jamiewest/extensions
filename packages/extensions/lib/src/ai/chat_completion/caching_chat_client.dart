import 'dart:async';

import '../../system/threading/cancellation_token.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response.dart';
import 'chat_response_update.dart';
import 'delegating_chat_client.dart';

/// An abstract [DelegatingChatClient] that caches chat responses.
///
/// Subclasses provide the actual caching mechanism by implementing
/// [getCachedResponse] and [setCachedResponse].
abstract class CachingChatClient extends DelegatingChatClient {
  /// Creates a new [CachingChatClient].
  CachingChatClient(super.innerClient);

  /// Gets a cache key for the given messages and options.
  ///
  /// Override to customize cache key generation.
  String getCacheKey(
    Iterable<ChatMessage> messages,
    ChatOptions? options,
  ) {
    final buffer = StringBuffer();
    for (final message in messages) {
      buffer.write(message.role.value);
      buffer.write(':');
      buffer.write(message.text);
      buffer.write('|');
    }
    if (options?.modelId != null) {
      buffer.write('model:${options!.modelId}');
    }
    return buffer.toString();
  }

  /// Retrieves a cached response for the given key, or `null` if
  /// not found.
  Future<ChatResponse?> getCachedResponse(String key);

  /// Stores a response in the cache with the given key.
  Future<void> setCachedResponse(String key, ChatResponse response);

  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final key = getCacheKey(messages, options);
    final cached = await getCachedResponse(key);
    if (cached != null) return cached;

    final response = await super.getChatResponse(
      messages: messages,
      options: options,
      cancellationToken: cancellationToken,
    );

    await setCachedResponse(key, response);
    return response;
  }

  @override
  Stream<ChatResponseUpdate> getStreamingChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      // Caching of streaming responses is not supported by default.
      // Subclasses can override this to provide caching for streaming.
      super.getStreamingChatResponse(
        messages: messages,
        options: options,
        cancellationToken: cancellationToken,
      );
}

import 'dart:async';

import 'package:extensions/annotations.dart';

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
@Source(
  name: 'CachingChatClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/ChatCompletion/',
  commit: 'b56aec451afe841d1865da4c9cb45fd5a379a519',
)
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
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final key = getCacheKey(messages, options);
    final cached = await getCachedResponse(key);
    if (cached != null) return cached;

    final response = await super.getResponse(
      messages: messages,
      options: options,
      cancellationToken: cancellationToken,
    );

    await setCachedResponse(key, response);
    return response;
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      // Caching of streaming responses is not supported by default.
      // Subclasses can override this to provide caching for streaming.
      super.getStreamingResponse(
        messages: messages,
        options: options,
        cancellationToken: cancellationToken,
      );
}

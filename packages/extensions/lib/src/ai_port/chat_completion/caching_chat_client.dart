import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/chat_completion/chat_response_update.dart';
import '../abstractions/chat_completion/delegating_chat_client.dart';

/// Represents a delegating chat client that caches the results of chat calls.
abstract class CachingChatClient extends DelegatingChatClient {
  /// Initializes a new instance of the [CachingChatClient] class.
  ///
  /// [innerClient] The underlying [ChatClient].
  const CachingChatClient(ChatClient innerClient);

  /// A boxed `true` value.
  static final Object _boxedTrue = true;

  /// A boxed `false` value.
  static final Object _boxedFalse = false;

  /// Gets or sets a value indicating whether streaming updates are coalesced.
  bool coalesceStreamingUpdates = true;

  @override
  Future<ChatResponse> getResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) {
    _ = Throw.ifNull(messages);
    return enableCaching(messages, options) ?
            getCachedResponseAsync(messages, options, cancellationToken) :
            base.getResponseAsync(messages, options, cancellationToken);
  }

  Future<ChatResponse> getCachedResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    var cacheKey = getCacheKey(messages, options, _boxedFalse);
    if (await readCacheAsync(cacheKey, cancellationToken) is not { } result) {
      result = await base.getResponseAsync(messages, options, cancellationToken);
      await writeCacheAsync(cacheKey, result, cancellationToken);
    }
    return result;
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) {
    _ = Throw.ifNull(messages);
    return enableCaching(messages, options) ?
            getCachedStreamingResponseAsync(messages, options, cancellationToken) :
            base.getStreamingResponseAsync(messages, options, cancellationToken);
  }

  Stream<ChatResponseUpdate> getCachedStreamingResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    if (coalesceStreamingUpdates) {
      var cacheKey = getCacheKey(messages, options, _boxedTrue);
      if (await readCacheAsync(cacheKey, cancellationToken) is { } chatResponse) {
        for (final chunk in chatResponse.toChatResponseUpdates()) {
          yield chunk;
        }
      } else {
        var capturedItems = [];
        for (final chunk in base.getStreamingResponseAsync(messages, options, cancellationToken)) {
          capturedItems.add(chunk);
          yield chunk;
        }
        // Write the captured items to the cache as a non-streaming result.
                await writeCacheAsync(cacheKey, capturedItems.toChatResponse(), cancellationToken);
      }
    } else {
      var cacheKey = getCacheKey(messages, options, _boxedTrue);
      if (await readCacheStreamingAsync(cacheKey, cancellationToken) is { } existingChunks) {
        var conversationId = null;
        for (final chunk in existingChunks) {
          conversationId ??= chunk.conversationId;
          yield chunk;
        }
      } else {
        var capturedItems = [];
        for (final chunk in base.getStreamingResponseAsync(messages, options, cancellationToken)) {
          capturedItems.add(chunk);
          yield chunk;
        }
        // Write the captured items to the cache.
                await writeCacheStreamingAsync(cacheKey, capturedItems, cancellationToken);
      }
    }
  }

  /// Computes a cache key for the specified values.
  ///
  /// Returns: The computed key.
  ///
  /// [messages] The messages to inform the key.
  ///
  /// [options] The [ChatOptions] to inform the key.
  ///
  /// [additionalValues] Any other values to inform the key.
  String getCacheKey(
    Iterable<ChatMessage> messages,
    ChatOptions? options,
    ReadOnlySpan<Object?> additionalValues,
  );
  /// Returns a previously cached [ChatResponse], if available. This is used
  /// when there is a call to [CancellationToken)].
  ///
  /// Returns: The previously cached data, if available, otherwise `null`.
  ///
  /// [key] The cache key.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests.
  Future<ChatResponse?> readCache(String key, CancellationToken cancellationToken, );
  /// Returns a previously cached list of [ChatResponseUpdate] values, if
  /// available. This is used when there is a call to [CancellationToken)].
  ///
  /// Returns: The previously cached data, if available, otherwise `null`.
  ///
  /// [key] The cache key.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests.
  Future<List<ChatResponseUpdate>?> readCacheStreaming(
    String key,
    CancellationToken cancellationToken,
  );
  /// Stores a [ChatResponse] in the underlying cache. This is used when there
  /// is a call to [CancellationToken)].
  ///
  /// Returns: A [Task] representing the completion of the operation.
  ///
  /// [key] The cache key.
  ///
  /// [value] The [ChatResponse] to be stored.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests.
  Future writeCache(String key, ChatResponse value, CancellationToken cancellationToken, );
  /// Stores a list of [ChatResponseUpdate] values in the underlying cache. This
  /// is used when there is a call to [CancellationToken)].
  ///
  /// Returns: A [Task] representing the completion of the operation.
  ///
  /// [key] The cache key.
  ///
  /// [value] The [ChatResponse] to be stored.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests.
  Future writeCacheStreaming(
    String key,
    List<ChatResponseUpdate> value,
    CancellationToken cancellationToken,
  );
  /// Determines whether caching should be used with the specified request.
  ///
  /// Remarks: The default implementation returns `true` as long as the
  /// `options` does not have a [ConversationId] set.
  ///
  /// Returns: `true` if caching should be used for the request, such that the
  /// [CachingChatClient] will try to satisfy the request from the cache, or if
  /// it can't, will try to cache the fetched response. `false` if caching
  /// should not be used for the request, such that the request will be passed
  /// through to the inner [ChatClient] without attempting to read from or write
  /// to the cache.
  ///
  /// [messages] The sequence of chat messages included in the request.
  ///
  /// [options] The chat options included in the request.
  bool enableCaching(Iterable<ChatMessage> messages, ChatOptions? options, ) {
    return options?.conversationId == null;
  }
}

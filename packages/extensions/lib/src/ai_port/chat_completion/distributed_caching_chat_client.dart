import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/chat_completion/chat_response_update.dart';
import 'caching_chat_client.dart';

/// A delegating chat client that caches the results of response calls,
/// storing them as JSON in an [DistributedCache].
///
/// Remarks: The [DistributedCachingChatClient] employs JSON serialization as
/// part of storing cached data. It is not guaranteed that the object models
/// used by [ChatMessage], [ChatOptions], [ChatResponse],
/// [ChatResponseUpdate], or any of the other objects in the chat client
/// pipeline will roundtrip through JSON serialization with full fidelity. For
/// example, [RawRepresentation] will be ignored, and [Object] values in
/// [AdditionalProperties] will deserialize as [JsonElement] rather than as
/// the original type. In general, code using [DistributedCachingChatClient]
/// should only rely on accessing data that can be preserved well enough
/// through JSON serialization and deserialization. The provided
/// implementation of [ChatClient] is thread-safe for concurrent use so long
/// as the employed [DistributedCache] is similarly thread-safe for concurrent
/// use.
class DistributedCachingChatClient extends CachingChatClient {
  /// Initializes a new instance of the [DistributedCachingChatClient] class.
  ///
  /// [innerClient] The underlying [ChatClient].
  ///
  /// [storage] An [DistributedCache] instance that will be used as the backing
  /// store for the cache.
  DistributedCachingChatClient(
    ChatClient innerClient,
    DistributedCache storage,
  ) : _storage = Throw.ifNull(storage);

  /// Boxed cache version.
  ///
  /// Remarks: Bump the cache version to invalidate existing caches if the
  /// serialization format changes in a breaking way.
  static final Object _cacheVersion = 2;

  /// The [DistributedCache] instance that will be used as the backing store for
  /// the cache.
  final DistributedCache _storage;

  /// Additional values used to inform the cache key employed for storing state.
  List<Object>? _cacheKeyAdditionalValues;

  /// Gets or sets JSON serialization options to use when serializing cache
  /// data.
  JsonSerializerOptions jsonSerializerOptions = AIJsonUtilities.DefaultOptions;

  /// Gets or sets additional values used to inform the cache key employed for
  /// storing state.
  ///
  /// Remarks: Any values set in this list will augment the other values used to
  /// inform the cache key.
  List<Object>? cacheKeyAdditionalValues;

  @override
  Future<ChatResponse?> readCache(String key, CancellationToken cancellationToken, ) async  {
    _ = Throw.ifNull(key);
    jsonSerializerOptions.makeReadOnly();
    if (await _storage.getAsync(key, cancellationToken) is byte[] existingJson) {
      return (ChatResponse?)JsonSerializer.deserialize(existingJson, jsonSerializerOptions.getTypeInfo(typeof(ChatResponse)));
    }
    return null;
  }

  @override
  Future<List<ChatResponseUpdate>?> readCacheStreaming(
    String key,
    CancellationToken cancellationToken,
  ) async  {
    _ = Throw.ifNull(key);
    jsonSerializerOptions.makeReadOnly();
    if (await _storage.getAsync(key, cancellationToken) is byte[] existingJson) {
      return (IReadOnlyList<ChatResponseUpdate>?)JsonSerializer.deserialize(existingJson, jsonSerializerOptions.getTypeInfo(typeof(IReadOnlyList<ChatResponseUpdate>)));
    }
    return null;
  }

  @override
  Future writeCache(String key, ChatResponse value, CancellationToken cancellationToken, ) async  {
    _ = Throw.ifNull(key);
    _ = Throw.ifNull(value);
    jsonSerializerOptions.makeReadOnly();
    var newJson = JsonSerializer.serializeToUtf8Bytes(
      value,
      jsonSerializerOptions.getTypeInfo(typeof(ChatResponse)),
    );
    await _storage.setAsync(key, newJson, cancellationToken);
  }

  @override
  Future writeCacheStreaming(
    String key,
    List<ChatResponseUpdate> value,
    CancellationToken cancellationToken,
  ) async  {
    _ = Throw.ifNull(key);
    _ = Throw.ifNull(value);
    jsonSerializerOptions.makeReadOnly();
    var newJson = JsonSerializer.serializeToUtf8Bytes(
      value,
      jsonSerializerOptions.getTypeInfo(typeof(IReadOnlyList<ChatResponseUpdate>)),
    );
    await _storage.setAsync(key, newJson, cancellationToken);
  }

  /// Computes a cache key for the specified values.
  ///
  /// Remarks: The `messages`, `options`, and `additionalValues` are serialized
  /// to JSON using [JsonSerializerOptions] in order to compute the key. The
  /// generated cache key is not guaranteed to be stable across releases of the
  /// library.
  ///
  /// Returns: The computed key.
  ///
  /// [messages] The messages to inform the key.
  ///
  /// [options] The [ChatOptions] to inform the key.
  ///
  /// [additionalValues] Any other values to inform the key.
  @override
  String getCacheKey(
    Iterable<ChatMessage> messages,
    ChatOptions? options,
    ReadOnlySpan<Object?> additionalValues,
  ) {
    var FixedValuesCount = 3;
    var clientValues = _cacheKeyAdditionalValues ?? Array.empty<Object>();
    var length = FixedValuesCount + additionalValues.length + clientValues.length;
    var arr = ArrayPool<Object?>.shared.rent(length);
    try {
      arr[0] = _cacheVersion;
      arr[1] = messages;
      arr[2] = options;
      additionalValues.copyTo(arr.asSpan(FixedValuesCount));
      clientValues.copyTo(arr, FixedValuesCount + additionalValues.length);
      return AIJsonUtilities.hashDataToString(arr.asSpan(0, length), jsonSerializerOptions);
    } finally {
      Array.clear(arr, 0, length);
      ArrayPool<Object?>.shared.returnValue(arr);
    }
  }
}

import 'caching_embedding_generator.dart';

/// Represents a delegating embedding generator that caches the results of
/// embedding generation calls, storing them as JSON in an [DistributedCache].
///
/// Remarks: The provided implementation of [EmbeddingGenerator] is
/// thread-safe for concurrent use so long as the employed [DistributedCache]
/// is similarly thread-safe for concurrent use.
///
/// [TInput] The type from which embeddings will be generated.
///
/// [TEmbedding] The type of embeddings to generate.
class DistributedCachingEmbeddingGenerator<TInput,TEmbedding> extends CachingEmbeddingGenerator<TInput, TEmbedding> {
  /// Initializes a new instance of the [DistributedCachingEmbeddingGenerator]
  /// class.
  ///
  /// [innerGenerator] The underlying [EmbeddingGenerator].
  ///
  /// [storage] A [DistributedCache] instance that will be used as the backing
  /// store for the cache.
  DistributedCachingEmbeddingGenerator(
    EmbeddingGenerator<TInput, TEmbedding> innerGenerator,
    DistributedCache storage,
  ) :
      _storage = storage,
      _jsonSerializerOptions = AIJsonUtilities.defaultOptions {
    _ = Throw.ifNull(storage);
  }

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

  /// Additional cache key values used to inform the key employed for storing
  /// state.
  JsonSerializerOptions _jsonSerializerOptions;

  /// Gets or sets JSON serialization options to use when serializing cache
  /// data.
  JsonSerializerOptions jsonSerializerOptions;

  /// Gets or sets additional values used to inform the cache key employed for
  /// storing state.
  ///
  /// Remarks: Any values set in this list will augment the other values used to
  /// inform the cache key.
  List<Object>? cacheKeyAdditionalValues;

  @override
  Future<TEmbedding?> readCache(String key, CancellationToken cancellationToken, ) async  {
    _ = Throw.ifNull(key);
    _jsonSerializerOptions.makeReadOnly();
    if (await _storage.getAsync(key, cancellationToken) is byte[] existingJson) {
      return JsonSerializer.deserialize(
        existingJson,
        (JsonTypeInfo<TEmbedding>)_jsonSerializerOptions.getTypeInfo(typeof(TEmbedding)),
      );
    }
    return null;
  }

  @override
  Future writeCache(String key, TEmbedding value, CancellationToken cancellationToken, ) async  {
    _ = Throw.ifNull(key);
    _ = Throw.ifNull(value);
    _jsonSerializerOptions.makeReadOnly();
    var newJson = JsonSerializer.serializeToUtf8Bytes(
      value,
      (JsonTypeInfo<TEmbedding>)_jsonSerializerOptions.getTypeInfo(typeof(TEmbedding)),
    );
    await _storage.setAsync(key, newJson, cancellationToken);
  }

  /// Computes a cache key for the specified values.
  ///
  /// Remarks: The `values` are serialized to JSON using [JsonSerializerOptions]
  /// in order to compute the key. The generated cache key is not guaranteed to
  /// be stable across releases of the library.
  ///
  /// Returns: The computed key.
  ///
  /// [values] The values to inform the key.
  @override
  String getCacheKey(ReadOnlySpan<Object?> values) {
    var FixedValuesCount = 1;
    var clientValues = _cacheKeyAdditionalValues ?? Array.empty<Object>();
    var length = FixedValuesCount + clientValues.length + values.length;
    var arr = ArrayPool<Object?>.shared.rent(length);
    try {
      arr[0] = _cacheVersion;
      values.copyTo(arr.asSpan(FixedValuesCount));
      clientValues.copyTo(arr, FixedValuesCount + values.length);
      return AIJsonUtilities.hashDataToString(arr.asSpan(0, length), _jsonSerializerOptions);
    } finally {
      Array.clear(arr, 0, length);
      ArrayPool<Object?>.shared.returnValue(arr);
    }
  }
}

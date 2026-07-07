import 'dart:convert';
import 'dart:typed_data';

import '../../caching/distributed_cache.dart';
import '../../caching/distributed_cache_entry_options.dart';
import 'caching_embedding_generator.dart';
import 'embedding.dart';

/// A [CachingEmbeddingGenerator] that stores embeddings in a
/// [DistributedCache].
///
/// Embeddings are stored as JSON by default; supply [serializeEmbedding]
/// and [deserializeEmbedding] to customize the wire format. The default
/// codec round-trips the vector, model id, and creation time, but not
/// `additionalProperties`.
class DistributedCachingEmbeddingGenerator extends CachingEmbeddingGenerator {
  final DistributedCache _storage;
  final DistributedCacheEntryOptions? _cacheOptions;
  final Uint8List Function(Embedding embedding)? _serialize;
  final Embedding Function(Uint8List data)? _deserialize;

  /// Creates a new [DistributedCachingEmbeddingGenerator] backed by
  /// [storage].
  DistributedCachingEmbeddingGenerator(
    super.innerGenerator, {
    required DistributedCache storage,
    DistributedCacheEntryOptions? cacheOptions,
    Uint8List Function(Embedding embedding)? serializeEmbedding,
    Embedding Function(Uint8List data)? deserializeEmbedding,
  })  : _storage = storage,
        _cacheOptions = cacheOptions,
        _serialize = serializeEmbedding,
        _deserialize = deserializeEmbedding;

  @override
  Future<Embedding?> getCachedEmbedding(String key) async {
    final data = await _storage.get(key);
    if (data == null) {
      return null;
    }
    return (_deserialize ?? _defaultDeserialize)(data);
  }

  @override
  Future<void> setCachedEmbedding(String key, Embedding embedding) =>
      _storage.set(
        key,
        (_serialize ?? _defaultSerialize)(embedding),
        _cacheOptions,
      );

  static Uint8List _defaultSerialize(Embedding embedding) =>
      Uint8List.fromList(utf8.encode(jsonEncode(<String, Object?>{
        'vector': embedding.vector,
        'modelId': embedding.modelId,
        'createdAt': embedding.createdAt?.toIso8601String(),
      })));

  static Embedding _defaultDeserialize(Uint8List data) {
    final json = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
    return Embedding(
      vector: (json['vector'] as List<dynamic>)
          .map((value) => (value as num).toDouble())
          .toList(),
      modelId: json['modelId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

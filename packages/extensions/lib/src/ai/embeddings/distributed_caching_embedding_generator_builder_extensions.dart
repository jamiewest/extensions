import 'dart:typed_data';

import '../../caching/distributed_cache.dart';
import '../../caching/distributed_cache_entry_options.dart';
import '../../dependency_injection/service_provider_service_extensions.dart';
import 'distributed_caching_embedding_generator.dart';
import 'embedding.dart';
import 'embedding_generator_builder.dart';

/// Provides extensions for adding [DistributedCachingEmbeddingGenerator] to
/// an [EmbeddingGeneratorBuilder] pipeline.
extension DistributedCachingEmbeddingGeneratorBuilderExtensions
    on EmbeddingGeneratorBuilder {
  /// Adds per-value embedding caching backed by a [DistributedCache].
  ///
  /// When [storage] is omitted, it is resolved from the service provider at
  /// build time.
  EmbeddingGeneratorBuilder useDistributedCache({
    DistributedCache? storage,
    DistributedCacheEntryOptions? cacheOptions,
    Uint8List Function(Embedding embedding)? serializeEmbedding,
    Embedding Function(Uint8List data)? deserializeEmbedding,
    void Function(DistributedCachingEmbeddingGenerator generator)? configure,
  }) =>
      useWithServices((inner, services) {
        final generator = DistributedCachingEmbeddingGenerator(
          inner,
          storage: storage ?? services.getRequiredService<DistributedCache>(),
          cacheOptions: cacheOptions,
          serializeEmbedding: serializeEmbedding,
          deserializeEmbedding: deserializeEmbedding,
        );
        configure?.call(generator);
        return generator;
      });
}

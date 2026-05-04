import '../../../../../lib/func_typedefs.dart';
import 'distributed_caching_embedding_generator.dart';
import 'embedding_generator_builder.dart';

/// Extension methods for adding a [DistributedCachingEmbeddingGenerator] to
/// an [EmbeddingGenerator] pipeline.
extension DistributedCachingEmbeddingGeneratorBuilderExtensions on EmbeddingGeneratorBuilder<TInput, TEmbedding> {
  /// Adds a [DistributedCachingEmbeddingGenerator] as the next stage in the
/// pipeline.
///
/// Returns: The [EmbeddingGeneratorBuilder] provided as `builder`.
///
/// [builder] The [EmbeddingGeneratorBuilder].
///
/// [storage] An optional [DistributedCache] instance that will be used as the
/// backing store for the cache. If not supplied, an instance will be resolved
/// from the service provider.
///
/// [configure] An optional callback that can be used to configure the
/// [DistributedCachingEmbeddingGenerator] instance.
///
/// [TInput] The type from which embeddings will be generated.
///
/// [TEmbedding] The type of embeddings to generate.
EmbeddingGeneratorBuilder<TInput, TEmbedding> useDistributedCache<TEmbedding>({DistributedCache? storage, Action<DistributedCachingEmbeddingGenerator<TInput, TEmbedding>>? configure, }) {
_ = Throw.ifNull(builder);
return builder.use((innerGenerator, services) =>
        {
            storage ??= services.getRequiredService<DistributedCache>();
            var result = new DistributedCachingEmbeddingGenerator<TInput, TEmbedding>(
              innerGenerator,
              storage,
            );
            configure?.invoke(result);
            return result;
        });
 }
 }

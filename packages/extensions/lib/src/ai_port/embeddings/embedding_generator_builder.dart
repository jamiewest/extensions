import '../../../../../lib/func_typedefs.dart';
import '../abstractions/embeddings/embedding_generation_options.dart';
import '../abstractions/embeddings/generated_embeddings.dart';
import '../empty_service_provider.dart';

/// A builder for creating pipelines of [EmbeddingGenerator].
///
/// [TInput] The type from which embeddings will be generated.
///
/// [TEmbedding] The type of embeddings to generate.
class EmbeddingGeneratorBuilder<TInput,TEmbedding> {
  /// Initializes a new instance of the [EmbeddingGeneratorBuilder] class.
  ///
  /// [innerGenerator] The inner [EmbeddingGeneratorBuilder] that represents the
  /// underlying backend.
  EmbeddingGeneratorBuilder({EmbeddingGenerator<TInput, TEmbedding>? innerGenerator = null, Func<ServiceProvider, EmbeddingGenerator<TInput, TEmbedding>>? innerGeneratorFactory = null, }) : _innerGeneratorFactory = _ => innerGenerator {
    _ = Throw.ifNull(innerGenerator);
  }

  final Func<ServiceProvider, EmbeddingGenerator<TInput, TEmbedding>> _innerGeneratorFactory;

  /// The registered client factory instances.
  List<Func2<EmbeddingGenerator<TInput, TEmbedding>, ServiceProvider, EmbeddingGenerator<TInput, TEmbedding>>>? _generatorFactories;

  /// Builds an [EmbeddingGenerator] that represents the entire pipeline. Calls
  /// to this instance will pass through each of the pipeline stages in turn.
  ///
  /// Returns: An instance of [EmbeddingGenerator] that represents the entire
  /// pipeline.
  ///
  /// [services] The [ServiceProvider] that should provide services to the
  /// [EmbeddingGenerator] instances. If `null`, an empty [ServiceProvider] will
  /// be used.
  EmbeddingGenerator<TInput, TEmbedding> build({ServiceProvider? services}) {
    services ??= EmptyServiceProvider.instance;
    var embeddingGenerator = _innerGeneratorFactory(services);
    if (_generatorFactories != null) {
      for (var i = _generatorFactories.count - 1; i >= 0; i--) {
        embeddingGenerator = _generatorFactories[i](embeddingGenerator, services);
        if (embeddingGenerator == null) {
          Throw.invalidOperationException(
                        'The ${nameof(IEmbeddingGenerator<TInput, TEmbedding>)} entry at index ${i} returned null. ' +
                        'Ensure that the callbacks passed to ${nameof(Use)} return non-null ${nameof(IEmbeddingGenerator<TInput, TEmbedding>)} instances.');
        }
      }
    }
    return embeddingGenerator;
  }

  /// Adds a factory for an intermediate embedding generator to the embedding
  /// generator pipeline.
  ///
  /// Returns: The updated [EmbeddingGeneratorBuilder] instance.
  ///
  /// [generatorFactory] The generator factory function.
  EmbeddingGeneratorBuilder<TInput, TEmbedding> use({Func<EmbeddingGenerator<TInput, TEmbedding>, EmbeddingGenerator<TInput, TEmbedding>>? generatorFactory, Func4<Iterable<TInput>, EmbeddingGenerationOptions?, EmbeddingGenerator<TInput, TEmbedding>, CancellationToken, Future<GeneratedEmbeddings<TEmbedding>>>? generateFunc, }) {
    _ = Throw.ifNull(generatorFactory);
    return use((innerGenerator, _) => generatorFactory(innerGenerator));
  }
}

import 'embedding_generation_options.dart';
import 'generated_embeddings.dart';

/// Provides an optional base class for an [EmbeddingGenerator] that passes
/// through calls to another instance.
///
/// Remarks: This type is recommended as a base type when building generators
/// that can be chained around an underlying [EmbeddingGenerator]. The default
/// implementation simply passes each call to the inner generator instance.
///
/// [TInput] The type of the input passed to the generator.
///
/// [TEmbedding] The type of the embedding instance produced by the generator.
class DelegatingEmbeddingGenerator<TInput, TEmbedding>
    implements EmbeddingGenerator<TInput, TEmbedding> {
  /// Initializes a new instance of the [DelegatingEmbeddingGenerator] class.
  ///
  /// [innerGenerator] The wrapped generator instance.
  const DelegatingEmbeddingGenerator(
    EmbeddingGenerator<TInput, TEmbedding> innerGenerator,
  ) : innerGenerator = Throw.ifNull(innerGenerator);

  /// Gets the inner [EmbeddingGenerator].
  final EmbeddingGenerator<TInput, TEmbedding> innerGenerator;

  /// Provides a mechanism for releasing unmanaged resources.
  ///
  /// [disposing] `true` if being called from [Dispose]; otherwise, `false`.
  @override
  void dispose({bool? disposing}) {
    if (disposing) {
      innerGenerator.dispose();
    }
  }

  @override
  Future<GeneratedEmbeddings<TEmbedding>> generate(
    Iterable<TInput> values, {
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerGenerator.generateAsync(values, options, cancellationToken);
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey}) {
    _ = Throw.ifNull(serviceType);
    return serviceKey == null && serviceType.isInstanceOfType(this)
        ? this
        : innerGenerator.getService(serviceType, serviceKey);
  }
}

import 'embedding_generator_builder.dart';

/// Provides extension methods for working with [EmbeddingGenerator] in the
/// context of [EmbeddingGeneratorBuilder].
extension EmbeddingGeneratorBuilderEmbeddingGeneratorExtensions
    on EmbeddingGenerator<TInput, TEmbedding> {
  /// Creates a new [EmbeddingGeneratorBuilder] using `innerGenerator` as its
  /// inner generator.
  ///
  /// Remarks: This method is equivalent to using the
  /// [EmbeddingGeneratorBuilder] constructor directly, specifying
  /// `innerGenerator` as the inner generator.
  ///
  /// Returns: The new [EmbeddingGeneratorBuilder] instance.
  ///
  /// [innerGenerator] The generator to use as the inner generator.
  ///
  /// [TInput] The type from which embeddings will be generated.
  ///
  /// [TEmbedding] The type of embeddings to generate.
  EmbeddingGeneratorBuilder<TInput, TEmbedding> asBuilder<TEmbedding>() {
    _ = Throw.ifNull(innerGenerator);
    return new EmbeddingGeneratorBuilder<TInput, TEmbedding>(innerGenerator);
  }
}

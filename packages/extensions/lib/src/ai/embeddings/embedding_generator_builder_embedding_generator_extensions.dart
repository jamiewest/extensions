import 'embedding_generator.dart';
import 'embedding_generator_builder.dart';

/// Provides extension methods for working with [EmbeddingGenerator] in the
/// context of [EmbeddingGeneratorBuilder].
extension EmbeddingGeneratorBuilderEmbeddingGeneratorExtensions
    on EmbeddingGenerator {
  /// Creates a new [EmbeddingGeneratorBuilder] using this generator as its
  /// inner generator.
  EmbeddingGeneratorBuilder asBuilder() => EmbeddingGeneratorBuilder(this);
}

import 'configure_options_embedding_generator.dart';
import 'embedding_generation_options.dart';
import 'embedding_generator_builder.dart';

/// Provides extensions for adding [ConfigureOptionsEmbeddingGenerator] to an
/// [EmbeddingGeneratorBuilder] pipeline.
extension ConfigureOptionsEmbeddingGeneratorBuilderExtensions
    on EmbeddingGeneratorBuilder {
  /// Adds a callback that configures the [EmbeddingGenerationOptions]
  /// passed to each request.
  EmbeddingGeneratorBuilder useConfigureOptions(
    EmbeddingGenerationOptions Function(EmbeddingGenerationOptions options)
    configure,
  ) => use(
    (inner) => ConfigureOptionsEmbeddingGenerator(inner, configure: configure),
  );
}

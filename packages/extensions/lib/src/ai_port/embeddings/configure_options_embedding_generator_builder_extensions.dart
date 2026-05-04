import '../../../../../lib/func_typedefs.dart';
import '../abstractions/embeddings/embedding_generation_options.dart';
import 'configure_options_embedding_generator.dart';
import 'embedding_generator_builder.dart';

/// Provides extensions for configuring [ConfigureOptionsEmbeddingGenerator]
/// instances.
extension ConfigureOptionsEmbeddingGeneratorBuilderExtensions
    on EmbeddingGeneratorBuilder<TInput, TEmbedding> {
  /// Adds a callback that configures a [EmbeddingGenerationOptions] to be
  /// passed to the next client in the pipeline.
  ///
  /// Remarks: This can be used to set default options. The `configure` delegate
  /// is passed either a new instance of [EmbeddingGenerationOptions] if the
  /// caller didn't supply a [EmbeddingGenerationOptions] instance, or a clone
  /// (via [Clone] of the caller-supplied instance if one was supplied.
  ///
  /// Returns: The `builder`.
  ///
  /// [builder] The [EmbeddingGeneratorBuilder].
  ///
  /// [configure] The delegate to invoke to configure the
  /// [EmbeddingGenerationOptions] instance. It is passed a clone of the
  /// caller-supplied [EmbeddingGenerationOptions] instance (or a new
  /// constructed instance if the caller-supplied instance is `null`).
  ///
  /// [TInput] The type of the input passed to the generator.
  ///
  /// [TEmbedding] The type of the embedding instance produced by the generator.
  EmbeddingGeneratorBuilder<TInput, TEmbedding> configureOptions<TEmbedding>(
    Action<EmbeddingGenerationOptions> configure,
  ) {
    _ = Throw.ifNull(builder);
    _ = Throw.ifNull(configure);
    return builder.use(
      (innerGenerator) =>
          new ConfigureOptionsEmbeddingGenerator<TInput, TEmbedding>(
            innerGenerator,
            configure,
          ),
    );
  }
}

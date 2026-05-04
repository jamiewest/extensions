import '../../../../../lib/func_typedefs.dart';
import '../abstractions/embeddings/delegating_embedding_generator.dart';
import '../abstractions/embeddings/embedding_generation_options.dart';
import '../abstractions/embeddings/generated_embeddings.dart';

/// Represents a delegating embedding generator that configures a
/// [EmbeddingGenerationOptions] instance used by the remainder of the
/// pipeline.
///
/// [TInput] The type of the input passed to the generator.
///
/// [TEmbedding] The type of the embedding instance produced by the generator.
class ConfigureOptionsEmbeddingGenerator<TInput,TEmbedding> extends DelegatingEmbeddingGenerator<TInput, TEmbedding> {
  /// Initializes a new instance of the [ConfigureOptionsEmbeddingGenerator]
  /// class with the specified `configure` callback.
  ///
  /// Remarks: The `configure` delegate is passed either a new instance of
  /// [EmbeddingGenerationOptions] if the caller didn't supply a
  /// [EmbeddingGenerationOptions] instance, or a clone (via [Clone] of the
  /// caller-supplied instance if one was supplied.
  ///
  /// [innerGenerator] The inner generator.
  ///
  /// [configure] The delegate to invoke to configure the
  /// [EmbeddingGenerationOptions] instance. It is passed a clone of the
  /// caller-supplied [EmbeddingGenerationOptions] instance (or a newly
  /// constructed instance if the caller-supplied instance is `null`).
  const ConfigureOptionsEmbeddingGenerator(
    EmbeddingGenerator<TInput, TEmbedding> innerGenerator,
    Action<EmbeddingGenerationOptions> configure,
  ) : _configureOptions = Throw.ifNull(configure);

  /// The callback delegate used to configure options.
  final Action<EmbeddingGenerationOptions> _configureOptions;

  @override
  Future<GeneratedEmbeddings<TEmbedding>> generate(
    Iterable<TInput> values,
    {EmbeddingGenerationOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    return await base.generateAsync(values, configure(options), cancellationToken);
  }

  /// Creates and configures the [EmbeddingGenerationOptions] to pass along to
  /// the inner client.
  EmbeddingGenerationOptions configure(EmbeddingGenerationOptions? options) {
    options = options?.clone() ?? new();
    _configureOptions(options);
    return options;
  }
}

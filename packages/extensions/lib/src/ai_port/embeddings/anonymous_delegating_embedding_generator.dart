import '../../../../../lib/func_typedefs.dart';
import '../abstractions/embeddings/delegating_embedding_generator.dart';
import '../abstractions/embeddings/embedding_generation_options.dart';
import '../abstractions/embeddings/generated_embeddings.dart';

/// A delegating embedding generator that wraps an inner generator with
/// implementations provided by delegates.
///
/// [TInput] The type from which embeddings will be generated.
///
/// [TEmbedding] The type of embeddings to generate.
class AnonymousDelegatingEmbeddingGenerator<TInput, TEmbedding>
    extends DelegatingEmbeddingGenerator<TInput, TEmbedding> {
  /// Initializes a new instance of the [AnonymousDelegatingEmbeddingGenerator]
  /// class.
  ///
  /// [innerGenerator] The inner generator.
  ///
  /// [generateFunc] A delegate that provides the implementation for
  /// [CancellationToken)].
  AnonymousDelegatingEmbeddingGenerator(
    EmbeddingGenerator<TInput, TEmbedding> innerGenerator,
    Func4<
      Iterable<TInput>,
      EmbeddingGenerationOptions?,
      EmbeddingGenerator<TInput, TEmbedding>,
      CancellationToken,
      Future<GeneratedEmbeddings<TEmbedding>>
    >
    generateFunc,
  ) : _generateFunc = generateFunc {
    _ = Throw.ifNull(generateFunc);
  }

  /// The delegate to use as the implementation of [CancellationToken)].
  final Func4<
    Iterable<TInput>,
    EmbeddingGenerationOptions?,
    EmbeddingGenerator<TInput, TEmbedding>,
    CancellationToken,
    Future<GeneratedEmbeddings<TEmbedding>>
  >
  _generateFunc;

  @override
  Future<GeneratedEmbeddings<TEmbedding>> generate(
    Iterable<TInput> values, {
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    _ = Throw.ifNull(values);
    return await _generateFunc(
      values,
      options,
      InnerGenerator,
      cancellationToken,
    );
  }
}

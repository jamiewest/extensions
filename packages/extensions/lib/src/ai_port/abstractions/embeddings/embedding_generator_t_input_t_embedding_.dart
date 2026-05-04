import 'embedding_generation_options.dart';
import 'generated_embeddings.dart';

/// Represents a generator of embeddings.
///
/// Remarks: Unless otherwise specified, all members of [EmbeddingGenerator]
/// are thread-safe for concurrent use. It is expected that all
/// implementations of [EmbeddingGenerator] support being used by multiple
/// requests concurrently. Instances must not be disposed of while the
/// instance is still in use. However, implementations of [EmbeddingGenerator]
/// may mutate the arguments supplied to [CancellationToken)], such as by
/// configuring the options instance. Thus, consumers of the interface either
/// should avoid using shared instances of these arguments for concurrent
/// invocations or should otherwise ensure by construction that no
/// [EmbeddingGenerator] instances are used which might employ such mutation.
///
/// [TInput] The type from which embeddings will be generated.
///
/// [TEmbedding] The type of embeddings to generate.
abstract class EmbeddingGenerator<TInput, TEmbedding> {
  /// Generates embeddings for each of the supplied `values`.
  ///
  /// Returns: The generated embeddings.
  ///
  /// [values] The sequence of values for which to generate embeddings.
  ///
  /// [options] The embedding generation options with which to configure the
  /// request.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests. The default is [None].
  Future<GeneratedEmbeddings<TEmbedding>> generate(
    Iterable<TInput> values, {
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  });
}

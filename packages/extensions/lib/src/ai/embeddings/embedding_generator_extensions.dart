import '../../system/exceptions/invalid_operation_exception.dart';
import '../../system/threading/cancellation_token.dart';
import 'embedding.dart';
import 'embedding_generation_options.dart';
import 'embedding_generator.dart';

/// Convenience operations for [EmbeddingGenerator].
///
/// The upstream `GetService`/`GetRequiredService` overloads collapse into
/// the interface's own [EmbeddingGenerator.getService] per the porting
/// rules and are not repeated here.
///
/// This is an experimental feature.
extension EmbeddingGeneratorExtensions on EmbeddingGenerator {
  /// Generates an embedding for the single [value].
  ///
  /// Throws [InvalidOperationException] when the generator does not return
  /// exactly one embedding for the one input.
  Future<Embedding> generateEmbedding(
    String value, {
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final embeddings = await generateEmbeddings(
      values: [value],
      options: options,
      cancellationToken: cancellationToken,
    );
    if (embeddings.length != 1) {
      throw InvalidOperationException(
        message:
            'Expected the number of embeddings (${embeddings.length}) '
            'to match the number of inputs (1).',
      );
    }
    return embeddings[0];
  }

  /// Generates an embedding for [value] and returns its raw vector.
  Future<List<double>> generateVector(
    String value, {
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final embedding = await generateEmbedding(
      value,
      options: options,
      cancellationToken: cancellationToken,
    );
    return embedding.vector;
  }

  /// Generates embeddings for [values] and pairs each input with its
  /// embedding.
  ///
  /// Throws [InvalidOperationException] when the generator does not return
  /// exactly one embedding per input.
  Future<List<(String, Embedding)>> generateAndZip(
    Iterable<String> values, {
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final inputs = values.toList();
    if (inputs.isEmpty) {
      return const [];
    }
    final embeddings = await generateEmbeddings(
      values: inputs,
      options: options,
      cancellationToken: cancellationToken,
    );
    if (embeddings.length != inputs.length) {
      throw InvalidOperationException(
        message:
            'Expected the number of embeddings (${embeddings.length}) '
            'to match the number of inputs (${inputs.length}).',
      );
    }
    return [for (var i = 0; i < inputs.length; i++) (inputs[i], embeddings[i])];
  }
}

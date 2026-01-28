import '../../system/threading/cancellation_token.dart';
import 'embedding_generation_options.dart';
import 'embedding_generator.dart';
import 'generated_embeddings.dart';

/// An [EmbeddingGenerator] that delegates all calls to an inner generator.
///
/// Subclass this to create middleware that wraps specific methods
/// while delegating others.
abstract class DelegatingEmbeddingGenerator implements EmbeddingGenerator {
  /// Creates a new [DelegatingEmbeddingGenerator] wrapping [innerGenerator].
  DelegatingEmbeddingGenerator(this.innerGenerator);

  /// The inner generator to delegate to.
  final EmbeddingGenerator innerGenerator;

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerGenerator.generateEmbeddings(
        values: values,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  T? getService<T>({Object? key}) =>
      innerGenerator.getService<T>(key: key);

  @override
  void dispose() => innerGenerator.dispose();
}

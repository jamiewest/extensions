import '../../system/disposable.dart';
import '../../system/threading/cancellation_token.dart';
import 'embedding_generation_options.dart';
import 'generated_embeddings.dart';

/// Represents an embedding generator.
abstract class EmbeddingGenerator implements Disposable {
  /// Generates embeddings for the given [values].
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Gets a service of the specified type.
  T? getService<T>({Object? key}) => null;
}

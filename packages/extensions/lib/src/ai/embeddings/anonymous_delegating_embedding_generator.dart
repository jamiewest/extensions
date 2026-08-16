import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import 'delegating_embedding_generator.dart';
import 'embedding_generation_options.dart';
import 'embedding_generator.dart';
import 'generated_embeddings.dart';

/// The signature of the callback wrapped by
/// [AnonymousDelegatingEmbeddingGenerator].
typedef GenerateEmbeddingsHandler = Future<GeneratedEmbeddings> Function(
  Iterable<String> values,
  EmbeddingGenerationOptions? options,
  EmbeddingGenerator innerGenerator,
  CancellationToken? cancellationToken,
);

/// A [DelegatingEmbeddingGenerator] whose behavior is supplied as a
/// callback rather than a subclass.
///
/// This is an experimental feature.
@Source(
  name: 'AnonymousDelegatingEmbeddingGenerator.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/Embeddings/',
)
class AnonymousDelegatingEmbeddingGenerator
    extends DelegatingEmbeddingGenerator {
  /// Creates a generator that routes [generateEmbeddings] through
  /// [generateHandler].
  AnonymousDelegatingEmbeddingGenerator(
    super.innerGenerator, {
    required this._generateHandler,
  });

  final GenerateEmbeddingsHandler _generateHandler;

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) => _generateHandler(values, options, innerGenerator, cancellationToken);
}

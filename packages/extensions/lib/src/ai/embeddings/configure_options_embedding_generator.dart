import '../../system/threading/cancellation_token.dart';
import 'delegating_embedding_generator.dart';
import 'embedding_generation_options.dart';
import 'generated_embeddings.dart';

/// A delegating embedding generator that applies configuration to
/// [EmbeddingGenerationOptions] before each request.
class ConfigureOptionsEmbeddingGenerator
    extends DelegatingEmbeddingGenerator {
  /// Creates a new [ConfigureOptionsEmbeddingGenerator].
  ///
  /// [configure] is called before each request to modify the options.
  ConfigureOptionsEmbeddingGenerator(
    super.innerGenerator, {
    required this.configure,
  });

  /// The callback that configures options before each request.
  final EmbeddingGenerationOptions Function(EmbeddingGenerationOptions options)
      configure;

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      super.generateEmbeddings(
        values: values,
        options: configure(options ?? EmbeddingGenerationOptions()),
        cancellationToken: cancellationToken,
      );
}

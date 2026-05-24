import 'package:extensions/annotations.dart';

import '../../ai/embeddings/embedding.dart';
import '../../ai/embeddings/embedding_generator.dart';
import '../../system/threading/cancellation_token.dart';
import 'vector_property_model.dart';

/// Encapsulates runtime embedding generation dispatch for a specific
/// [Embedding] subtype.
///
/// Each instance handles both the embedding-type resolution at model-build
/// time and the actual generation at runtime for one concrete embedding type.
/// Providers create instances via [EmbeddingGenerationDispatcher.create].
///
/// This is a support type for provider implementors; application code should
/// not reference it directly.
@Source(
  name: 'EmbeddingGenerationDispatcher.cs',
  namespace: 'Microsoft.Extensions.VectorData.ProviderServices',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/'
      'ProviderServices/',
)
abstract class EmbeddingGenerationDispatcher {
  /// Creates a dispatcher backed by the given [generateBatch] and
  /// [generateSingle] callbacks.
  ///
  /// [embeddingType] is the [Embedding] subtype this dispatcher produces.
  static EmbeddingGenerationDispatcher create(
    Type embeddingType, {
    required Future<List<Embedding>> Function(
      VectorPropertyModel property,
      Iterable<Object?> values,
      CancellationToken? cancellationToken,
    ) generateBatch,
    required Future<Embedding> Function(
      VectorPropertyModel property,
      Object? value,
      CancellationToken? cancellationToken,
    ) generateSingle,
  }) =>
      _CallbackDispatcher(
        embeddingType: embeddingType,
        generateBatch: generateBatch,
        generateSingle: generateSingle,
      );

  /// Creates the default dispatcher, which uses the property's configured
  /// [EmbeddingGenerator] to produce [Embedding] values.
  static EmbeddingGenerationDispatcher createDefault() => create(
        Embedding,
        generateBatch: (property, values, token) async {
          final gen = property.embeddingGenerator!;
          final result = await gen.generateEmbeddings(
            values: values.whereType<String>(),
            cancellationToken: token,
          );
          return result.toList();
        },
        generateSingle: (property, value, token) async {
          final gen = property.embeddingGenerator!;
          final result = await gen.generateEmbeddings(
            values: [value as String],
            cancellationToken: token,
          );
          return result[0];
        },
      );

  /// The [Embedding] type this dispatcher produces.
  Type get embeddingType;

  /// Attempts to resolve the embedding output type for [vectorProperty] given
  /// [embeddingGenerator].
  ///
  /// Returns [embeddingType] when the generator is compatible with this
  /// dispatcher, [userRequestedEmbeddingType] when provided and compatible, or
  /// `null` when the generator cannot produce this dispatcher's embedding type.
  Type? resolveEmbeddingType(
    VectorPropertyModel vectorProperty,
    EmbeddingGenerator embeddingGenerator,
    Type? userRequestedEmbeddingType,
  );

  /// Returns whether [embeddingGenerator] can produce this dispatcher's
  /// [embeddingType] for inputs appropriate to [vectorProperty].
  bool canGenerateEmbedding(
    VectorPropertyModel vectorProperty,
    EmbeddingGenerator embeddingGenerator,
  );

  /// Generates embeddings for [values] using the generator configured on
  /// [vectorProperty].
  Future<List<Embedding>> generateEmbeddingsAsync(
    VectorPropertyModel vectorProperty,
    Iterable<Object?> values,
    CancellationToken? cancellationToken,
  );

  /// Generates a single embedding for [value] using the generator configured
  /// on [vectorProperty].
  Future<Embedding> generateEmbeddingAsync(
    VectorPropertyModel vectorProperty,
    Object? value,
    CancellationToken? cancellationToken,
  );
}

final class _CallbackDispatcher extends EmbeddingGenerationDispatcher {
  _CallbackDispatcher({
    required this.embeddingType,
    required Future<List<Embedding>> Function(
      VectorPropertyModel,
      Iterable<Object?>,
      CancellationToken?,
    ) generateBatch,
    required Future<Embedding> Function(
      VectorPropertyModel,
      Object?,
      CancellationToken?,
    ) generateSingle,
  })  : _generateBatch = generateBatch,
        _generateSingle = generateSingle;

  @override
  final Type embeddingType;

  final Future<List<Embedding>> Function(
    VectorPropertyModel,
    Iterable<Object?>,
    CancellationToken?,
  ) _generateBatch;

  final Future<Embedding> Function(
    VectorPropertyModel,
    Object?,
    CancellationToken?,
  ) _generateSingle;

  @override
  Type? resolveEmbeddingType(
    VectorPropertyModel vectorProperty,
    EmbeddingGenerator embeddingGenerator,
    Type? userRequestedEmbeddingType,
  ) {
    if (userRequestedEmbeddingType != null &&
        userRequestedEmbeddingType != embeddingType) {
      return null;
    }
    return embeddingType;
  }

  @override
  bool canGenerateEmbedding(
    VectorPropertyModel vectorProperty,
    EmbeddingGenerator embeddingGenerator,
  ) =>
      true;

  @override
  Future<List<Embedding>> generateEmbeddingsAsync(
    VectorPropertyModel vectorProperty,
    Iterable<Object?> values,
    CancellationToken? cancellationToken,
  ) =>
      _generateBatch(vectorProperty, values, cancellationToken);

  @override
  Future<Embedding> generateEmbeddingAsync(
    VectorPropertyModel vectorProperty,
    Object? value,
    CancellationToken? cancellationToken,
  ) =>
      _generateSingle(vectorProperty, value, cancellationToken);
}

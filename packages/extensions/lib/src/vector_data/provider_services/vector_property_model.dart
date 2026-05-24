import 'package:extensions/annotations.dart';

import '../../ai/embeddings/embedding.dart';
import '../../ai/embeddings/embedding_generator.dart';
import '../../system/threading/cancellation_token.dart';
import 'embedding_generation_dispatcher.dart';
import 'property_model.dart';

/// Represents a vector property on a vector store record.
///
/// This is a support type for provider implementors; application code should
/// not reference it directly.
@Source(
  name: 'VectorPropertyModel.cs',
  namespace: 'Microsoft.Extensions.VectorData.ProviderServices',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/'
      'ProviderServices/',
)
class VectorPropertyModel extends PropertyModel {
  /// Creates a [VectorPropertyModel] with the given [modelName] and [type].
  VectorPropertyModel({
    required super.modelName,
    required super.type,
    super.isNullable,
  });

  int _dimensions = 0;

  /// The number of dimensions in the vector.
  ///
  /// Required when creating collections; may be omitted when only reading.
  int get dimensions => _dimensions;
  set dimensions(int value) {
    if (value <= 0) {
      throw ArgumentError.value(
        value,
        'dimensions',
        'Dimensions must be greater than zero.',
      );
    }
    _dimensions = value;
  }

  /// The kind of index to use for this vector property.
  ///
  /// Semantics vary by provider. See the provider documentation for supported
  /// values.
  String? indexKind;

  /// The distance function to use when comparing vectors.
  ///
  /// Semantics vary by provider. See the provider documentation for supported
  /// values.
  String? distanceFunction;

  /// The Dart [Type] of the embedding stored in the database when an
  /// [embeddingGenerator] is configured.
  ///
  /// When no generator is configured this equals [type].
  Type? embeddingType;

  /// The embedding generator to use for this property.
  EmbeddingGenerator? embeddingGenerator;

  /// The [EmbeddingGenerationDispatcher] resolved during model building for
  /// runtime embedding dispatch.
  ///
  /// Null for properties whose type is natively supported by the provider.
  EmbeddingGenerationDispatcher? embeddingGenerationDispatcher;

  /// Generates a batch of embeddings for [values] using the configured
  /// [embeddingGenerationDispatcher].
  ///
  /// Throws [StateError] if no dispatcher is configured.
  Future<List<Embedding>> generateEmbeddingsAsync(
    Iterable<Object?> values, {
    CancellationToken? cancellationToken,
  }) {
    final dispatcher = embeddingGenerationDispatcher;
    if (dispatcher == null) {
      throw StateError(
        "No embedding generation is configured for property '$modelName'.",
      );
    }
    return dispatcher.generateEmbeddingsAsync(
      this,
      values,
      cancellationToken,
    );
  }

  /// Generates a single embedding for [value] using the configured
  /// [embeddingGenerationDispatcher].
  ///
  /// Throws [StateError] if no dispatcher is configured.
  Future<Embedding> generateEmbeddingAsync(
    Object? value, {
    CancellationToken? cancellationToken,
  }) {
    final dispatcher = embeddingGenerationDispatcher;
    if (dispatcher == null) {
      throw StateError(
        "No embedding generation is configured for property '$modelName'.",
      );
    }
    return dispatcher.generateEmbeddingAsync(
      this,
      value,
      cancellationToken,
    );
  }

  @override
  String toString() => '$modelName (Vector, $type)';
}

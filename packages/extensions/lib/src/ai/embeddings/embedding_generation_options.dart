import '../additional_properties_dictionary.dart';

/// Options for embedding generation requests.
class EmbeddingGenerationOptions {
  /// Creates a new [EmbeddingGenerationOptions].
  EmbeddingGenerationOptions({
    this.modelId,
    this.dimensions,
    this.additionalProperties,
  });

  /// The model to use for generation.
  String? modelId;

  /// The requested number of dimensions for the embedding.
  int? dimensions;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Creates a deep copy of this [EmbeddingGenerationOptions].
  EmbeddingGenerationOptions clone() => EmbeddingGenerationOptions(
        modelId: modelId,
        dimensions: dimensions,
        additionalProperties: additionalProperties != null
            ? Map.of(additionalProperties!)
            : null,
      );
}

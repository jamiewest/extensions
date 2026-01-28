/// Provides metadata about an embedding generator.
class EmbeddingGeneratorMetadata {
  /// Creates a new [EmbeddingGeneratorMetadata].
  EmbeddingGeneratorMetadata({
    this.providerName,
    this.providerUri,
    this.defaultModelId,
    this.defaultModelDimensions,
  });

  /// The name of the provider.
  final String? providerName;

  /// The URI of the provider.
  final Uri? providerUri;

  /// The default model identifier.
  final String? defaultModelId;

  /// The default number of dimensions for the model.
  final int? defaultModelDimensions;
}

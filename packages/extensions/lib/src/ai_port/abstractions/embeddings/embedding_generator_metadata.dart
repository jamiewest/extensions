/// Provides metadata about an [EmbeddingGenerator].
class EmbeddingGeneratorMetadata {
  /// Initializes a new instance of the [EmbeddingGeneratorMetadata] class.
  ///
  /// [providerName] The name of the embedding generation provider, if
  /// applicable. Where possible, this should map to the appropriate name
  /// defined in the OpenTelemetry Semantic Conventions for Generative AI
  /// systems.
  ///
  /// [providerUri] The URL for accessing the embedding generation provider, if
  /// applicable.
  ///
  /// [defaultModelId] The ID of the default embedding generation model used, if
  /// applicable.
  ///
  /// [defaultModelDimensions] The number of dimensions in vectors produced by
  /// the default model, if applicable.
  EmbeddingGeneratorMetadata({
    String? providerName = null,
    Uri? providerUri = null,
    String? defaultModelId = null,
    int? defaultModelDimensions = null,
  }) : defaultModelId = defaultModelId,
       providerName = providerName,
       providerUri = providerUri,
       defaultModelDimensions = defaultModelDimensions;

  /// Gets the name of the embedding generation provider.
  ///
  /// Remarks: Where possible, this maps to the appropriate name defined in the
  /// OpenTelemetry Semantic Conventions for Generative AI systems.
  final String? providerName;

  /// Gets the URL for accessing the embedding generation provider.
  final Uri? providerUri;

  /// Gets the ID of the default model used by this embedding generator.
  ///
  /// Remarks: This value can be `null` if no default model is set on the
  /// corresponding embedding generator. An individual request may override this
  /// value via [ModelId].
  final String? defaultModelId;

  /// Gets the number of dimensions in the embeddings produced by the default
  /// model.
  ///
  /// Remarks: This value can be `null` if either the number of dimensions is
  /// unknown or there are multiple possible lengths associated with this model.
  /// An individual request may override this value via [Dimensions].
  final int? defaultModelDimensions;
}

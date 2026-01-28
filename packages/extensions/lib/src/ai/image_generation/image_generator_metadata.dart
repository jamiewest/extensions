/// Provides metadata about an image generator.
class ImageGeneratorMetadata {
  /// Creates a new [ImageGeneratorMetadata].
  ImageGeneratorMetadata({
    this.providerName,
    this.providerUri,
    this.defaultModelId,
  });

  /// The name of the provider.
  final String? providerName;

  /// The URI of the provider.
  final Uri? providerUri;

  /// The default model identifier.
  final String? defaultModelId;
}

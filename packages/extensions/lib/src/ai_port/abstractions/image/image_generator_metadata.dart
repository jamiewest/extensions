import 'image_generator.dart';

/// Provides metadata about an [ImageGenerator].
class ImageGeneratorMetadata {
  /// Initializes a new instance of the [ImageGeneratorMetadata] class.
  ///
  /// [providerName] The name of the image generation provider, if applicable.
  /// Where possible, this should map to the appropriate name defined in the
  /// OpenTelemetry Semantic Conventions for Generative AI systems.
  ///
  /// [providerUri] The URL for accessing the image generation provider, if
  /// applicable.
  ///
  /// [defaultModelId] The ID of the image generation model used by default, if
  /// applicable.
  ImageGeneratorMetadata({
    String? providerName = null,
    Uri? providerUri = null,
    String? defaultModelId = null,
  }) : defaultModelId = defaultModelId,
       providerName = providerName,
       providerUri = providerUri;

  /// Gets the name of the image generation provider.
  ///
  /// Remarks: Where possible, this maps to the appropriate name defined in the
  /// OpenTelemetry Semantic Conventions for Generative AI systems.
  final String? providerName;

  /// Gets the URL for accessing the image generation provider.
  final Uri? providerUri;

  /// Gets the ID of the default model used by this image generator.
  ///
  /// Remarks: This value can be `null` if no default model is set on the
  /// corresponding [ImageGenerator]. An individual request may override this
  /// value via [ModelId].
  final String? defaultModelId;
}

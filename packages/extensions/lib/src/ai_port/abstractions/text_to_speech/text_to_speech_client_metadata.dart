import 'text_to_speech_client.dart';

/// Provides metadata about an [TextToSpeechClient].
class TextToSpeechClientMetadata {
  /// Initializes a new instance of the [TextToSpeechClientMetadata] class.
  ///
  /// [providerName] The name of the text to speech provider, if applicable.
  /// Where possible, this should map to the appropriate name defined in the
  /// OpenTelemetry Semantic Conventions for Generative AI systems.
  ///
  /// [providerUri] The URL for accessing the text to speech provider, if
  /// applicable.
  ///
  /// [defaultModelId] The ID of the text to speech model used by default, if
  /// applicable.
  TextToSpeechClientMetadata({
    String? providerName = null,
    Uri? providerUri = null,
    String? defaultModelId = null,
  }) : defaultModelId = defaultModelId,
       providerName = providerName,
       providerUri = providerUri;

  /// Gets the name of the text to speech provider.
  ///
  /// Remarks: Where possible, this maps to the appropriate name defined in the
  /// OpenTelemetry Semantic Conventions for Generative AI systems.
  final String? providerName;

  /// Gets the URL for accessing the text to speech provider.
  final Uri? providerUri;

  /// Gets the ID of the default model used by this text to speech client.
  ///
  /// Remarks: This value can be null if either the name is unknown or there are
  /// multiple possible models associated with this instance. An individual
  /// request may override this value via [ModelId].
  final String? defaultModelId;
}

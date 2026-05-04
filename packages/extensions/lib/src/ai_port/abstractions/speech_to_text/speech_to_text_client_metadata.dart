import 'speech_to_text_client.dart';

/// Provides metadata about an [SpeechToTextClient].
class SpeechToTextClientMetadata {
  /// Initializes a new instance of the [SpeechToTextClientMetadata] class.
  ///
  /// [providerName] The name of the speech to text provider, if applicable.
  /// Where possible, this should map to the appropriate name defined in the
  /// OpenTelemetry Semantic Conventions for Generative AI systems.
  ///
  /// [providerUri] The URL for accessing the speech to text provider, if
  /// applicable.
  ///
  /// [defaultModelId] The ID of the speech to text used by default, if
  /// applicable.
  SpeechToTextClientMetadata({
    String? providerName = null,
    Uri? providerUri = null,
    String? defaultModelId = null,
  }) : defaultModelId = defaultModelId,
       providerName = providerName,
       providerUri = providerUri;

  /// Gets the name of the speech to text provider.
  ///
  /// Remarks: Where possible, this maps to the appropriate name defined in the
  /// OpenTelemetry Semantic Conventions for Generative AI systems.
  final String? providerName;

  /// Gets the URL for accessing the speech to text provider.
  final Uri? providerUri;

  /// Gets the ID of the default model used by this speech to text client.
  ///
  /// Remarks: This value can be null if either the name is unknown or there are
  /// multiple possible models associated with this instance. An individual
  /// request may override this value via [ModelId].
  final String? defaultModelId;
}

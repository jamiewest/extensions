/// Provides metadata about a speech-to-text client.
class SpeechToTextClientMetadata {
  /// Creates a new [SpeechToTextClientMetadata].
  SpeechToTextClientMetadata({
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

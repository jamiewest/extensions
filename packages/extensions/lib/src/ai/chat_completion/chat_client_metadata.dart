/// Provides metadata about a chat client.
class ChatClientMetadata {
  /// Creates a new [ChatClientMetadata].
  ChatClientMetadata({
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

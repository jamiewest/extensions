import 'chat_client.dart';

/// Provides metadata about an [ChatClient].
class ChatClientMetadata {
  /// Initializes a new instance of the [ChatClientMetadata] class.
  ///
  /// [providerName] The name of the chat provider, if applicable. Where
  /// possible, this should map to the appropriate name defined in the
  /// OpenTelemetry Semantic Conventions for Generative AI systems.
  ///
  /// [providerUri] The URL for accessing the chat provider, if applicable.
  ///
  /// [defaultModelId] The ID of the chat model used by default, if applicable.
  ChatClientMetadata({
    String? providerName = null,
    Uri? providerUri = null,
    String? defaultModelId = null,
  }) : defaultModelId = defaultModelId,
       providerName = providerName,
       providerUri = providerUri;

  /// Gets the name of the chat provider.
  ///
  /// Remarks: Where possible, this maps to the appropriate name defined in the
  /// OpenTelemetry Semantic Conventions for Generative AI systems.
  final String? providerName;

  /// Gets the URL for accessing the chat provider.
  final Uri? providerUri;

  /// Gets the ID of the default model used by this chat client.
  ///
  /// Remarks: This value can be `null` if no default model is set on the
  /// corresponding [ChatClient]. An individual request may override this value
  /// via [ModelId].
  final String? defaultModelId;
}

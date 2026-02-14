import 'package:extensions/annotations.dart';

/// Provides metadata about a chat client.
@Source(
  name: 'ChatClientMetadata.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/ChatCompletion/',
  commit: 'd256f6b3c15f358c6b9ad28958900238da4deb9d',
)
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

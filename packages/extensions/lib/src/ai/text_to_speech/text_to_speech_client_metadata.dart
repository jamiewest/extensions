import 'package:extensions/annotations.dart';

/// Provides metadata about a [TextToSpeechClient].
///
/// This is an experimental feature.
@Source(
  name: 'TextToSpeechClientMetadata.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/TextToSpeech/',
)
class TextToSpeechClientMetadata {
  /// Creates a new [TextToSpeechClientMetadata].
  const TextToSpeechClientMetadata({
    this.providerName,
    this.providerUri,
    this.defaultModelId,
  });

  /// The name of the text-to-speech provider.
  final String? providerName;

  /// The URL for accessing the provider.
  final Uri? providerUri;

  /// The default model ID used by this client.
  final String? defaultModelId;
}

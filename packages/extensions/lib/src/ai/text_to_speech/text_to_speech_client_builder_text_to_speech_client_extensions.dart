import 'text_to_speech_client.dart';
import 'text_to_speech_client_builder.dart';

/// Provides extension methods for working with [TextToSpeechClient] in the
/// context of [TextToSpeechClientBuilder].
///
/// This is an experimental feature.
extension TextToSpeechClientBuilderTextToSpeechClientExtensions
    on TextToSpeechClient {
  /// Creates a new [TextToSpeechClientBuilder] using this client as its
  /// inner client.
  TextToSpeechClientBuilder asBuilder() => TextToSpeechClientBuilder(this);
}

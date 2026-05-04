import '../abstractions/text_to_speech/text_to_speech_client.dart';
import 'text_to_speech_client_builder.dart';

/// Provides extension methods for working with [TextToSpeechClient] in the
/// context of [TextToSpeechClientBuilder].
extension TextToSpeechClientBuilderTextToSpeechClientExtensions
    on TextToSpeechClient {
  /// Creates a new [TextToSpeechClientBuilder] using `innerClient` as its inner
  /// client.
  ///
  /// Remarks: This method is equivalent to using the
  /// [TextToSpeechClientBuilder] constructor directly, specifying `innerClient`
  /// as the inner client.
  ///
  /// Returns: The new [TextToSpeechClientBuilder] instance.
  ///
  /// [innerClient] The client to use as the inner client.
  TextToSpeechClientBuilder asBuilder() {
    _ = Throw.ifNull(innerClient);
    return textToSpeechClientBuilder(innerClient);
  }
}

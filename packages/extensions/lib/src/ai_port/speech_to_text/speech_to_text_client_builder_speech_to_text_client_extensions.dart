import '../abstractions/speech_to_text/speech_to_text_client.dart';
import 'speech_to_text_client_builder.dart';

/// Provides extension methods for working with [SpeechToTextClient] in the
/// context of [SpeechToTextClientBuilder].
extension SpeechToTextClientBuilderSpeechToTextClientExtensions
    on SpeechToTextClient {
  /// Creates a new [SpeechToTextClientBuilder] using `innerClient` as its inner
  /// client.
  ///
  /// Remarks: This method is equivalent to using the
  /// [SpeechToTextClientBuilder] constructor directly, specifying `innerClient`
  /// as the inner client.
  ///
  /// Returns: The new [SpeechToTextClientBuilder] instance.
  ///
  /// [innerClient] The client to use as the inner client.
  SpeechToTextClientBuilder asBuilder() {
    _ = Throw.ifNull(innerClient);
    return speechToTextClientBuilder(innerClient);
  }
}

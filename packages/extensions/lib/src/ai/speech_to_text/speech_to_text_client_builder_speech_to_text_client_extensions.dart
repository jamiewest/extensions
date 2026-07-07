import 'speech_to_text_client.dart';
import 'speech_to_text_client_builder.dart';

/// Provides extension methods for working with [SpeechToTextClient] in the
/// context of [SpeechToTextClientBuilder].
///
/// This is an experimental feature.
extension SpeechToTextClientBuilderSpeechToTextClientExtensions
    on SpeechToTextClient {
  /// Creates a new [SpeechToTextClientBuilder] using this client as its
  /// inner client.
  SpeechToTextClientBuilder asBuilder() => SpeechToTextClientBuilder(this);
}

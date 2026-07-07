import 'configure_options_speech_to_text_client.dart';
import 'speech_to_text_client.dart';
import 'speech_to_text_client_builder.dart';

/// Provides extensions for adding [ConfigureOptionsSpeechToTextClient] to a
/// [SpeechToTextClientBuilder] pipeline.
///
/// This is an experimental feature.
extension ConfigureOptionsSpeechToTextClientBuilderExtensions
    on SpeechToTextClientBuilder {
  /// Adds a callback that configures the [SpeechToTextOptions] passed to
  /// each request.
  SpeechToTextClientBuilder useConfigureOptions(
          SpeechToTextOptions Function(SpeechToTextOptions options)
              configure) =>
      use(
        (inner) =>
            ConfigureOptionsSpeechToTextClient(inner, configure: configure),
      );
}

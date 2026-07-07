import 'configure_options_text_to_speech_client.dart';
import 'text_to_speech_client_builder.dart';
import 'text_to_speech_options.dart';

/// Provides extensions for adding [ConfigureOptionsTextToSpeechClient] to a
/// [TextToSpeechClientBuilder] pipeline.
///
/// This is an experimental feature.
extension ConfigureOptionsTextToSpeechClientBuilderExtensions
    on TextToSpeechClientBuilder {
  /// Adds a callback that configures the [TextToSpeechOptions] passed to
  /// each request.
  TextToSpeechClientBuilder useConfigureOptions(
          void Function(TextToSpeechOptions options) configure) =>
      use(
        (inner) =>
            ConfigureOptionsTextToSpeechClient(inner, configure: configure),
      );
}

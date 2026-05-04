import '../../../../../lib/func_typedefs.dart';
import '../abstractions/text_to_speech/text_to_speech_options.dart';
import 'configure_options_text_to_speech_client.dart';
import 'text_to_speech_client_builder.dart';

/// Provides extensions for configuring [ConfigureOptionsTextToSpeechClient]
/// instances.
extension ConfigureOptionsTextToSpeechClientBuilderExtensions
    on TextToSpeechClientBuilder {
  /// Adds a callback that configures a [TextToSpeechOptions] to be passed to
  /// the next client in the pipeline.
  ///
  /// Remarks: This method can be used to set default options. The `configure`
  /// delegate is passed either a new instance of [TextToSpeechOptions] if the
  /// caller didn't supply a [TextToSpeechOptions] instance, or a clone (via
  /// [Clone]) of the caller-supplied instance if one was supplied.
  ///
  /// Returns: The `builder`.
  ///
  /// [builder] The [TextToSpeechClientBuilder].
  ///
  /// [configure] The delegate to invoke to configure the [TextToSpeechOptions]
  /// instance. It is passed a clone of the caller-supplied
  /// [TextToSpeechOptions] instance (or a newly constructed instance if the
  /// caller-supplied instance is `null`).
  TextToSpeechClientBuilder configureOptions(
    Action<TextToSpeechOptions> configure,
  ) {
    _ = Throw.ifNull(builder);
    _ = Throw.ifNull(configure);
    return builder.use(
      (innerClient) =>
          configureOptionsTextToSpeechClient(innerClient, configure),
    );
  }
}

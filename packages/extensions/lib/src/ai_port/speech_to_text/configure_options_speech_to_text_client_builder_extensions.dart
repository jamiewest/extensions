import '../../../../../lib/func_typedefs.dart';
import '../abstractions/speech_to_text/speech_to_text_options.dart';
import 'configure_options_speech_to_text_client.dart';
import 'speech_to_text_client_builder.dart';

/// Provides extensions for configuring [ConfigureOptionsSpeechToTextClient]
/// instances.
extension ConfigureOptionsSpeechToTextClientBuilderExtensions
    on SpeechToTextClientBuilder {
  /// Adds a callback that configures a [SpeechToTextOptions] to be passed to
  /// the next client in the pipeline.
  ///
  /// Remarks: This method can be used to set default options. The `configure`
  /// delegate is passed either a new instance of [SpeechToTextOptions] if the
  /// caller didn't supply a [SpeechToTextOptions] instance, or a clone (via
  /// [Clone]) of the caller-supplied instance if one was supplied.
  ///
  /// Returns: The `builder`.
  ///
  /// [builder] The [SpeechToTextClientBuilder].
  ///
  /// [configure] The delegate to invoke to configure the [SpeechToTextOptions]
  /// instance. It is passed a clone of the caller-supplied
  /// [SpeechToTextOptions] instance (or a newly constructed instance if the
  /// caller-supplied instance is `null`).
  SpeechToTextClientBuilder configureOptions(
    Action<SpeechToTextOptions> configure,
  ) {
    _ = Throw.ifNull(builder);
    _ = Throw.ifNull(configure);
    return builder.use(
      (innerClient) =>
          configureOptionsSpeechToTextClient(innerClient, configure),
    );
  }
}

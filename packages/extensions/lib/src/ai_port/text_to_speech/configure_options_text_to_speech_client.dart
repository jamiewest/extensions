import '../../../../../lib/func_typedefs.dart';
import '../abstractions/text_to_speech/delegating_text_to_speech_client.dart';
import '../abstractions/text_to_speech/text_to_speech_client.dart';
import '../abstractions/text_to_speech/text_to_speech_options.dart';
import '../abstractions/text_to_speech/text_to_speech_response.dart';
import '../abstractions/text_to_speech/text_to_speech_response_update.dart';

/// Represents a delegating text to speech client that configures a
/// [TextToSpeechOptions] instance used by the remainder of the pipeline.
class ConfigureOptionsTextToSpeechClient extends DelegatingTextToSpeechClient {
  /// Initializes a new instance of the [ConfigureOptionsTextToSpeechClient]
  /// class with the specified `configure` callback.
  ///
  /// Remarks: The `configure` delegate is passed either a new instance of
  /// [TextToSpeechOptions] if the caller didn't supply a [TextToSpeechOptions]
  /// instance, or a clone (via [Clone] of the caller-supplied instance if one
  /// was supplied.
  ///
  /// [innerClient] The inner client.
  ///
  /// [configure] The delegate to invoke to configure the [TextToSpeechOptions]
  /// instance. It is passed a clone of the caller-supplied
  /// [TextToSpeechOptions] instance (or a newly constructed instance if the
  /// caller-supplied instance is `null`).
  const ConfigureOptionsTextToSpeechClient(
    TextToSpeechClient innerClient,
    Action<TextToSpeechOptions> configure,
  ) : _configureOptions = Throw.ifNull(configure);

  /// The callback delegate used to configure options.
  final Action<TextToSpeechOptions> _configureOptions;

  @override
  Future<TextToSpeechResponse> getAudio(
    String text,
    {TextToSpeechOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    return await base.getAudioAsync(text, configure(options), cancellationToken);
  }

  @override
  Stream<TextToSpeechResponseUpdate> getStreamingAudio(
    String text,
    {TextToSpeechOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    for (final update in base.getStreamingAudioAsync(text, configure(options), cancellationToken)) {
      yield update;
    }
  }

  /// Creates and configures the [TextToSpeechOptions] to pass along to the
  /// inner client.
  TextToSpeechOptions configure(TextToSpeechOptions? options) {
    options = options?.clone() ?? new();
    _configureOptions(options);
    return options;
  }
}

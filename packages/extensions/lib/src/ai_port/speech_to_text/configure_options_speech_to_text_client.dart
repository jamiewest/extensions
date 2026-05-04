import '../../../../../lib/func_typedefs.dart';
import '../abstractions/speech_to_text/delegating_speech_to_text_client.dart';
import '../abstractions/speech_to_text/speech_to_text_client.dart';
import '../abstractions/speech_to_text/speech_to_text_options.dart';
import '../abstractions/speech_to_text/speech_to_text_response.dart';
import '../abstractions/speech_to_text/speech_to_text_response_update.dart';

/// Represents a delegating chat client that configures a
/// [SpeechToTextOptions] instance used by the remainder of the pipeline.
class ConfigureOptionsSpeechToTextClient extends DelegatingSpeechToTextClient {
  /// Initializes a new instance of the [ConfigureOptionsSpeechToTextClient]
  /// class with the specified `configure` callback.
  ///
  /// Remarks: The `configure` delegate is passed either a new instance of
  /// [SpeechToTextOptions] if the caller didn't supply a [SpeechToTextOptions]
  /// instance, or a clone (via [Clone] of the caller-supplied instance if one
  /// was supplied.
  ///
  /// [innerClient] The inner client.
  ///
  /// [configure] The delegate to invoke to configure the [SpeechToTextOptions]
  /// instance. It is passed a clone of the caller-supplied
  /// [SpeechToTextOptions] instance (or a newly constructed instance if the
  /// caller-supplied instance is `null`).
  const ConfigureOptionsSpeechToTextClient(
    SpeechToTextClient innerClient,
    Action<SpeechToTextOptions> configure,
  ) : _configureOptions = Throw.ifNull(configure);

  /// The callback delegate used to configure options.
  final Action<SpeechToTextOptions> _configureOptions;

  @override
  Future<SpeechToTextResponse> getText(
    Stream audioSpeechStream,
    {SpeechToTextOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    return await base.getTextAsync(audioSpeechStream, configure(options), cancellationToken);
  }

  @override
  Stream<SpeechToTextResponseUpdate> getStreamingText(
    Stream audioSpeechStream,
    {SpeechToTextOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    for (final update in base.getStreamingTextAsync(audioSpeechStream, configure(options), cancellationToken)) {
      yield update;
    }
  }

  /// Creates and configures the [SpeechToTextOptions] to pass along to the
  /// inner client.
  SpeechToTextOptions configure(SpeechToTextOptions? options) {
    options = options?.clone() ?? new();
    _configureOptions(options);
    return options;
  }
}

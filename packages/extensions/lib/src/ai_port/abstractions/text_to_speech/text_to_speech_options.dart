import '../../../../../../lib/func_typedefs.dart';
import 'text_to_speech_client.dart';

/// Represents the options for a text to speech request.
class TextToSpeechOptions {
  /// Initializes a new instance of the [TextToSpeechOptions] class, performing
  /// a shallow copy of all properties from `other`.
  TextToSpeechOptions(TextToSpeechOptions? other) : additionalProperties = other.additionalProperties?.clone(), audioFormat = other.audioFormat, language = other.language, modelId = other.modelId, pitch = other.pitch, rawRepresentationFactory = other.rawRepresentationFactory, speed = other.speed, voiceId = other.voiceId, volume = other.volume {
    if (other == null) {
      return;
    }
  }

  /// Gets or sets the model ID for the text to speech request.
  String? modelId;

  /// Gets or sets the voice identifier to use for speech synthesis.
  String? voiceId;

  /// Gets or sets the language for the generated speech.
  ///
  /// Remarks: This is typically a BCP 47 language tag (e.g., "en-US", "fr-FR").
  String? language;

  /// Gets or sets the desired audio output format.
  ///
  /// Remarks: This may be a media type (e.g., "audio/mpeg") or a
  /// provider-specific format name (e.g., "mp3", "wav", "opus"). When not
  /// specified, the provider's default format is used.
  String? audioFormat;

  /// Gets or sets the speech speed multiplier.
  ///
  /// Remarks: A value of 1.0 represents normal speed. Values greater than 1.0
  /// increase speed; values less than 1.0 decrease speed. The valid range is
  /// provider-specific.
  double? speed;

  /// Gets or sets the speech pitch multiplier.
  ///
  /// Remarks: A value of 1.0 represents normal pitch. Values greater than 1.0
  /// increase pitch; values less than 1.0 decrease pitch. The valid range is
  /// provider-specific.
  double? pitch;

  /// Gets or sets the speech volume level.
  ///
  /// Remarks: The valid range and interpretation is provider-specific; a common
  /// convention is 0.0 (silent) to 1.0 (full volume).
  double? volume;

  /// Gets or sets any additional properties associated with the options.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets or sets a callback responsible for creating the raw representation of
  /// the text to speech options from an underlying implementation.
  ///
  /// Remarks: The underlying [TextToSpeechClient] implementation may have its
  /// own representation of options. When [CancellationToken)] or
  /// [CancellationToken)] is invoked with a [TextToSpeechOptions], that
  /// implementation may convert the provided options into its own
  /// representation in order to use it while performing the operation. For
  /// situations where a consumer knows which concrete [TextToSpeechClient] is
  /// being used and how it represents options, a new instance of that
  /// implementation-specific options type may be returned by this callback, for
  /// the [TextToSpeechClient] implementation to use instead of creating a new
  /// instance. Such implementations may mutate the supplied options instance
  /// further based on other settings supplied on this [TextToSpeechOptions]
  /// instance or from other inputs, therefore, it is strongly recommended to
  /// not return shared instances and instead make the callback return a new
  /// instance on each call. This is typically used to set an
  /// implementation-specific setting that isn't otherwise exposed from the
  /// strongly typed properties on [TextToSpeechOptions].
  Func<TextToSpeechClient, Object?>? rawRepresentationFactory;

  /// Produces a clone of the current [TextToSpeechOptions] instance.
  ///
  /// Returns: A clone of the current [TextToSpeechOptions] instance.
  TextToSpeechOptions clone() {
    return new(this);
  }
}

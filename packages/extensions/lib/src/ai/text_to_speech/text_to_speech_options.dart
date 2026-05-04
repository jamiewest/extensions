import 'package:extensions/annotations.dart';

import '../additional_properties_dictionary.dart';
import 'text_to_speech_client.dart';

/// Options for text-to-speech requests.
///
/// This is an experimental feature.
@Source(
  name: 'TextToSpeechOptions.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/TextToSpeech/',
)
class TextToSpeechOptions {
  /// Creates a new [TextToSpeechOptions].
  TextToSpeechOptions({
    this.modelId,
    this.voiceId,
    this.language,
    this.audioFormat,
    this.speed,
    this.pitch,
    this.volume,
    this.rawRepresentationFactory,
    this.additionalProperties,
  });

  /// The model to use for synthesis.
  String? modelId;

  /// The voice identifier to use.
  String? voiceId;

  /// The BCP 47 language tag for generated speech (e.g. `"en-US"`).
  String? language;

  /// The desired audio format (e.g. `"audio/mpeg"`, `"mp3"`, `"wav"`).
  String? audioFormat;

  /// Speech speed multiplier. `1.0` is normal speed.
  double? speed;

  /// Speech pitch multiplier. `1.0` is normal pitch.
  double? pitch;

  /// Speech volume multiplier. `1.0` is normal volume.
  double? volume;

  /// A callback that produces the implementation-specific options object.
  ///
  /// Return a new instance on each call — do not share instances.
  Object? Function(TextToSpeechClient)? rawRepresentationFactory;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Creates a shallow clone of this [TextToSpeechOptions].
  ///
  /// [rawRepresentationFactory] is not deep-cloned — the same reference is
  /// shared.
  TextToSpeechOptions clone() => TextToSpeechOptions(
        modelId: modelId,
        voiceId: voiceId,
        language: language,
        audioFormat: audioFormat,
        speed: speed,
        pitch: pitch,
        volume: volume,
        rawRepresentationFactory: rawRepresentationFactory,
        additionalProperties:
            additionalProperties != null ? Map.of(additionalProperties!) : null,
      );
}

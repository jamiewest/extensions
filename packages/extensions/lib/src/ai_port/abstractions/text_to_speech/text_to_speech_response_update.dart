import '../contents/ai_content.dart';
import 'text_to_speech_client.dart';
import 'text_to_speech_response.dart';
import 'text_to_speech_response_update_kind.dart';

/// Represents a single streaming response chunk from an [TextToSpeechClient].
///
/// Remarks: [TextToSpeechResponseUpdate] is so named because it represents
/// streaming updates to a text to speech generation. As such, it is
/// considered erroneous for multiple updates that are part of the same
/// request to contain competing values. For example, some updates that are
/// part of the same request may have a `null` value, and others may have a
/// non-`null` value, but all of those with a non-`null` value must have the
/// same value (e.g. [ResponseId]). The relationship between
/// [TextToSpeechResponse] and [TextToSpeechResponseUpdate] is codified in the
/// [CancellationToken)] and [ToTextToSpeechResponseUpdates], which enable
/// bidirectional conversions between the two. Note, however, that the
/// conversion may be slightly lossy, for example if multiple updates all have
/// different [RawRepresentation] objects whereas there's only one slot for
/// such an object available in [RawRepresentation].
class TextToSpeechResponseUpdate {
  /// Initializes a new instance of the [TextToSpeechResponseUpdate] class.
  ///
  /// [contents] The contents for this update.
  const TextToSpeechResponseUpdate(List<AContent> contents)
    : contents = Throw.ifNull(contents);

  /// Gets or sets the kind of the generated audio speech update.
  TextToSpeechResponseUpdateKind kind =
      TextToSpeechResponseUpdateKind.AudioUpdating;

  /// Gets or sets the ID of the generated audio speech response of which this
  /// update is a part.
  String? responseId;

  /// Gets or sets the model ID used in the creation of the text to speech of
  /// which this update is a part.
  String? modelId;

  /// Gets or sets the raw representation of the generated audio speech update
  /// from an underlying implementation.
  ///
  /// Remarks: If a [TextToSpeechResponseUpdate] is created to represent some
  /// underlying object from another object model, this property can be used to
  /// store that original object. This can be useful for debugging or for
  /// enabling a consumer to access the underlying object model if needed.
  Object? rawRepresentation;

  /// Gets or sets additional properties for the update.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets or sets the generated content items.
  List<AContent> contents;
}

import '../contents/ai_content.dart';
import '../contents/text_content.dart';
import 'speech_to_text_client.dart';
import 'speech_to_text_response.dart';
import 'speech_to_text_response_update_kind.dart';

/// Represents a single streaming response chunk from an [SpeechToTextClient].
///
/// Remarks: [SpeechToTextResponseUpdate] is so named because it represents
/// streaming updates to an speech to text generation. As such, it is
/// considered erroneous for multiple updates that are part of the same audio
/// speech to contain competing values. For example, some updates that are
/// part of the same audio speech may have a `null` value, and others may have
/// a non-`null` value, but all of those with a non-`null` value must have the
/// same value (e.g. [ResponseId]). The relationship between
/// [SpeechToTextResponse] and [SpeechToTextResponseUpdate] is codified in the
/// [CancellationToken)] and [ToSpeechToTextResponseUpdates], which enable
/// bidirectional conversions between the two. Note, however, that the
/// conversion may be slightly lossy, for example if multiple updates all have
/// different [RawRepresentation] objects whereas there's only one slot for
/// such an object available in [RawRepresentation].
class SpeechToTextResponseUpdate {
  /// Initializes a new instance of the [SpeechToTextResponseUpdate] class.
  ///
  /// [content] Content of the message.
  SpeechToTextResponseUpdate({
    List<AContent>? contents = null,
    String? content = null,
  });

  List<AContent>? _contents;

  /// Gets or sets the kind of the generated text update.
  SpeechToTextResponseUpdateKind kind =
      SpeechToTextResponseUpdateKind.TextUpdating;

  /// Gets or sets the ID of the generated text response of which this update is
  /// a part.
  String? responseId;

  /// Gets or sets the start time of the text segment associated with this
  /// update in relation to the full audio speech length.
  Duration? startTime;

  /// Gets or sets the end time of the text segment associated with this update
  /// in relation to the full audio speech length.
  Duration? endTime;

  /// Gets or sets the model ID using in the creation of the speech to text of
  /// which this update is a part.
  String? modelId;

  /// Gets or sets the raw representation of the generated text update from an
  /// underlying implementation.
  ///
  /// Remarks: If a [SpeechToTextResponseUpdate] is created to represent some
  /// underlying object from another object model, this property can be used to
  /// store that original object. This can be useful for debugging or for
  /// enabling a consumer to access the underlying object model if needed.
  Object? rawRepresentation;

  /// Gets or sets additional properties for the update.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets or sets the generated content items.
  List<AContent> contents;

  /// Gets the text of this speech to text response.
  ///
  /// Remarks: This property concatenates the text of all [TextContent] objects
  /// in [Contents].
  String get text {
    return _contents?.concatText() ?? string.empty;
  }

  @override
  String toString() {
    return text;
  }
}

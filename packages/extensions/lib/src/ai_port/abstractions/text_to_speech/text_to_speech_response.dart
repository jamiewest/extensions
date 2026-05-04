import '../contents/ai_content.dart';
import '../contents/usage_content.dart';
import '../usage_details.dart';
import 'text_to_speech_response_update.dart';
import 'text_to_speech_response_update_kind.dart';

/// Represents the result of a text to speech request.
class TextToSpeechResponse {
  /// Initializes a new instance of the [TextToSpeechResponse] class.
  ///
  /// [contents] The contents for this response.
  const TextToSpeechResponse(List<AContent> contents) : contents = Throw.ifNull(contents);

  /// Gets or sets the ID of the text to speech response.
  String? responseId;

  /// Gets or sets the model ID used in the creation of the text to speech
  /// response.
  String? modelId;

  /// Gets or sets the raw representation of the text to speech response from an
  /// underlying implementation.
  ///
  /// Remarks: If a [TextToSpeechResponse] is created to represent some
  /// underlying object from another object model, this property can be used to
  /// store that original object. This can be useful for debugging or for
  /// enabling a consumer to access the underlying object model if needed.
  Object? rawRepresentation;

  /// Gets or sets any additional properties associated with the text to speech
  /// response.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets or sets the generated content items.
  List<AContent> contents;

  /// Gets or sets usage details for the text to speech response.
  UsageDetails? usage;

  /// Creates an array of [TextToSpeechResponseUpdate] instances that represent
  /// this [TextToSpeechResponse].
  ///
  /// Returns: An array of [TextToSpeechResponseUpdate] instances that may be
  /// used to represent this [TextToSpeechResponse].
  List<TextToSpeechResponseUpdate> toTextToSpeechResponseUpdates() {
    var contents = contents;
    if (usage is { } usage) {
      contents = [.. contents, usageContent(usage)];
    }
    var update = new()
        {
            contents = contents,
            additionalProperties = additionalProperties,
            rawRepresentation = rawRepresentation,
            Kind = TextToSpeechResponseUpdateKind.audioUpdated,
            responseId = responseId,
            modelId = modelId,
        };
    return [update];
  }
}

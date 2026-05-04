import '../contents/ai_content.dart';
import '../contents/text_content.dart';
import '../contents/usage_content.dart';
import '../usage_details.dart';
import 'speech_to_text_response_update.dart';
import 'speech_to_text_response_update_kind.dart';

/// Represents the result of an speech to text request.
class SpeechToTextResponse {
  /// Initializes a new instance of the [SpeechToTextResponse] class.
  ///
  /// [content] Content of the response.
  SpeechToTextResponse({List<AContent>? contents = null, String? content = null, });

  /// The content items in the generated text response.
  List<AContent>? _contents;

  /// Gets or sets the start time of the text segment in relation to the full
  /// audio speech length.
  Duration? startTime;

  /// Gets or sets the end time of the text segment in relation to the full
  /// audio speech length.
  Duration? endTime;

  /// Gets or sets the ID of the speech to text response.
  String? responseId;

  /// Gets or sets the model ID used in the creation of the speech to text
  /// response.
  String? modelId;

  /// Gets or sets the raw representation of the speech to text response from an
  /// underlying implementation.
  ///
  /// Remarks: If a [SpeechToTextResponse] is created to represent some
  /// underlying object from another object model, this property can be used to
  /// store that original object. This can be useful for debugging or for
  /// enabling a consumer to access the underlying object model if needed.
  Object? rawRepresentation;

  /// Gets or sets any additional properties associated with the speech to text
  /// response.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets or sets the generated content items.
  List<AContent> contents;

  /// Gets or sets usage details for the speech to text response.
  UsageDetails? usage;

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

  /// Creates an array of [SpeechToTextResponseUpdate] instances that represent
  /// this [SpeechToTextResponse].
  ///
  /// Returns: An array of [SpeechToTextResponseUpdate] instances that may be
  /// used to represent this [SpeechToTextResponse].
  List<SpeechToTextResponseUpdate> toSpeechToTextResponseUpdates() {
    var contents = contents;
    if (usage is { } usage) {
      contents = [.. contents, usageContent(usage)];
    }
    var update = new()
        {
            contents = contents,
            additionalProperties = additionalProperties,
            rawRepresentation = rawRepresentation,
            startTime = startTime,
            endTime = endTime,
            Kind = SpeechToTextResponseUpdateKind.textUpdated,
            responseId = responseId,
            modelId = modelId,
        };
    return [update];
  }
}

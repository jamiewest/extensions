import '../additional_properties_dictionary.dart';
import '../data_content.dart';
import '../usage_details.dart';

/// The result of a text-to-speech request.
///
/// This is an experimental feature.
class TextToSpeechResponse {
  /// Creates a new [TextToSpeechResponse].
  TextToSpeechResponse({
    this.audio,
    this.responseId,
    this.modelId,
    this.usage,
    this.rawRepresentation,
    this.additionalProperties,
  });

  /// The generated audio content.
  DataContent? audio;

  /// A unique identifier for this response.
  String? responseId;

  /// The model that generated this response.
  String? modelId;

  /// Usage details for the request/response.
  UsageDetails? usage;

  /// The underlying implementation-specific object.
  Object? rawRepresentation;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;
}

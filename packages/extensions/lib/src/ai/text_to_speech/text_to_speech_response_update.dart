import 'package:extensions/annotations.dart';

import '../additional_properties_dictionary.dart';
import '../data_content.dart';

/// A single streaming response chunk from a [TextToSpeechClient].
///
/// This is an experimental feature.
@Source(
  name: 'TextToSpeechResponseUpdate.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/TextToSpeech/',
)
class TextToSpeechResponseUpdate {
  /// Creates a new [TextToSpeechResponseUpdate].
  TextToSpeechResponseUpdate({
    this.audio,
    this.responseId,
    this.modelId,
    this.rawRepresentation,
    this.additionalProperties,
  });

  /// Partial audio data for this update.
  DataContent? audio;

  /// The response ID shared across all updates for one request.
  String? responseId;

  /// The model that produced this update.
  String? modelId;

  /// The underlying implementation-specific object.
  Object? rawRepresentation;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;
}

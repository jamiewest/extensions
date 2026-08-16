import 'package:extensions/annotations.dart';

import '../additional_properties_dictionary.dart';
import '../data_content.dart';

/// The kind of a text-to-speech response update.
///
/// This is an experimental feature.
@Source(
  name: 'TextToSpeechResponseUpdateKind.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/TextToSpeech/',
)
class TextToSpeechResponseUpdateKind {
  /// Creates a new [TextToSpeechResponseUpdateKind].
  const TextToSpeechResponseUpdateKind(this.value);

  /// The string value of the kind.
  final String value;

  /// A session was opened.
  static const TextToSpeechResponseUpdateKind sessionOpen =
      TextToSpeechResponseUpdateKind('session_open');

  /// An error occurred.
  static const TextToSpeechResponseUpdateKind error =
      TextToSpeechResponseUpdateKind('error');

  /// Audio is being updated (a partial chunk).
  static const TextToSpeechResponseUpdateKind audioUpdating =
      TextToSpeechResponseUpdateKind('audio_updating');

  /// Audio has been finalized.
  static const TextToSpeechResponseUpdateKind audioUpdated =
      TextToSpeechResponseUpdateKind('audio_updated');

  /// A session was closed.
  static const TextToSpeechResponseUpdateKind sessionClose =
      TextToSpeechResponseUpdateKind('session_close');

  @override
  bool operator ==(Object other) =>
      other is TextToSpeechResponseUpdateKind &&
      value.toLowerCase() == other.value.toLowerCase();

  @override
  int get hashCode => value.toLowerCase().hashCode;

  @override
  String toString() => value;
}

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
    this.kind = TextToSpeechResponseUpdateKind.audioUpdating,
    this.audio,
    this.responseId,
    this.modelId,
    this.rawRepresentation,
    this.additionalProperties,
  });

  /// The kind of update, [TextToSpeechResponseUpdateKind.audioUpdating] by
  /// default to match the upstream property initializer.
  final TextToSpeechResponseUpdateKind kind;

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

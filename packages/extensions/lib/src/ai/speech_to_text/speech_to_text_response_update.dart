import '../additional_properties_dictionary.dart';
import '../ai_content.dart';
import '../text_content.dart';
import '../usage_details.dart';

/// The kind of a speech-to-text response update.
///
/// This is an experimental feature.
class SpeechToTextResponseUpdateKind {
  /// Creates a new [SpeechToTextResponseUpdateKind].
  const SpeechToTextResponseUpdateKind(this.value);

  /// The string value of the kind.
  final String value;

  /// A session was opened.
  static const SpeechToTextResponseUpdateKind sessionOpen =
      SpeechToTextResponseUpdateKind('session_open');

  /// An error occurred.
  static const SpeechToTextResponseUpdateKind error =
      SpeechToTextResponseUpdateKind('error');

  /// Text is being updated (partial/interim result).
  static const SpeechToTextResponseUpdateKind textUpdating =
      SpeechToTextResponseUpdateKind('text_updating');

  /// Text has been finalized.
  static const SpeechToTextResponseUpdateKind textUpdated =
      SpeechToTextResponseUpdateKind('text_updated');

  /// A session was closed.
  static const SpeechToTextResponseUpdateKind sessionClose =
      SpeechToTextResponseUpdateKind('session_close');

  @override
  bool operator ==(Object other) =>
      other is SpeechToTextResponseUpdateKind &&
      value.toLowerCase() == other.value.toLowerCase();

  @override
  int get hashCode => value.toLowerCase().hashCode;

  @override
  String toString() => value;
}

/// Represents a streaming update from a speech-to-text operation.
///
/// This is an experimental feature.
class SpeechToTextResponseUpdate {
  /// Creates a new [SpeechToTextResponseUpdate].
  SpeechToTextResponseUpdate({
    required this.kind,
    List<AIContent>? contents,
    this.startTime,
    this.endTime,
    this.responseId,
    this.modelId,
    this.rawRepresentation,
    this.additionalProperties,
    this.usage,
  }) : contents = contents ?? [];

  /// Creates an update from a text string.
  SpeechToTextResponseUpdate.fromText(
    this.kind,
    String text,
  )   : contents = [TextContent(text)],
        startTime = null,
        endTime = null,
        responseId = null,
        modelId = null,
        rawRepresentation = null,
        additionalProperties = null,
        usage = null;

  /// The kind of update.
  final SpeechToTextResponseUpdateKind kind;

  /// The content items.
  final List<AIContent> contents;

  /// The start time of the speech segment.
  Duration? startTime;

  /// The end time of the speech segment.
  Duration? endTime;

  /// A unique response identifier.
  String? responseId;

  /// The model that generated this update.
  String? modelId;

  /// The underlying implementation-specific object.
  Object? rawRepresentation;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Usage details.
  UsageDetails? usage;

  /// Gets concatenated text from all [TextContent] items.
  String get text => contents
      .whereType<TextContent>()
      .map((c) => c.text)
      .join();

  @override
  String toString() => text;
}

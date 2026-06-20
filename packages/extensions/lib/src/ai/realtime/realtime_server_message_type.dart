import 'package:extensions/annotations.dart';

/// Represents the type of a real-time server message.
///
/// Used to identify the message type being received from the model.
/// Well-known message types are provided as static constants. Providers may
/// define additional message types by constructing new instances with custom
/// values.
///
/// Provider implementations that want to support the built-in middleware
/// pipeline must emit [responseCreated], [responseDone], [responseOutputItemAdded],
/// and [responseOutputItemDone] at the appropriate points during response
/// generation.
///
/// This is an experimental feature.
@Source(
  name: 'RealtimeServerMessageType.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class RealtimeServerMessageType {
  /// Creates a new [RealtimeServerMessageType] with the given [value].
  const RealtimeServerMessageType(this.value);

  /// The value associated with this message type.
  final String value;

  /// Indicates that the response contains only raw content.
  static const RealtimeServerMessageType rawContentOnly =
      RealtimeServerMessageType('RawContentOnly');

  /// Indicates the output of audio transcription for user audio written to the
  /// user audio buffer.
  static const RealtimeServerMessageType inputAudioTranscriptionCompleted =
      RealtimeServerMessageType('InputAudioTranscriptionCompleted');

  /// Indicates the text value of an input audio transcription content part is
  /// updated with incremental transcription results.
  static const RealtimeServerMessageType inputAudioTranscriptionDelta =
      RealtimeServerMessageType('InputAudioTranscriptionDelta');

  /// Indicates that the audio transcription for user audio written to the user
  /// audio buffer has failed.
  static const RealtimeServerMessageType inputAudioTranscriptionFailed =
      RealtimeServerMessageType('InputAudioTranscriptionFailed');

  /// Indicates the output text update with incremental results.
  static const RealtimeServerMessageType outputTextDelta =
      RealtimeServerMessageType('OutputTextDelta');

  /// Indicates the output text is complete.
  static const RealtimeServerMessageType outputTextDone =
      RealtimeServerMessageType('OutputTextDone');

  /// Indicates the model-generated transcription of audio output updated.
  static const RealtimeServerMessageType outputAudioTranscriptionDelta =
      RealtimeServerMessageType('OutputAudioTranscriptionDelta');

  /// Indicates the model-generated transcription of audio output is done
  /// streaming.
  static const RealtimeServerMessageType outputAudioTranscriptionDone =
      RealtimeServerMessageType('OutputAudioTranscriptionDone');

  /// Indicates the audio output updated.
  static const RealtimeServerMessageType outputAudioDelta =
      RealtimeServerMessageType('OutputAudioDelta');

  /// Indicates the audio output is done streaming.
  static const RealtimeServerMessageType outputAudioDone =
      RealtimeServerMessageType('OutputAudioDone');

  /// Indicates the response has completed.
  static const RealtimeServerMessageType responseDone =
      RealtimeServerMessageType('ResponseDone');

  /// Indicates the response has been created.
  static const RealtimeServerMessageType responseCreated =
      RealtimeServerMessageType('ResponseCreated');

  /// Indicates an individual output item in the response has completed.
  static const RealtimeServerMessageType responseOutputItemDone =
      RealtimeServerMessageType('ResponseOutputItemDone');

  /// Indicates an individual output item has been added to the response.
  static const RealtimeServerMessageType responseOutputItemAdded =
      RealtimeServerMessageType('ResponseOutputItemAdded');

  /// Indicates a conversation item has been added.
  static const RealtimeServerMessageType conversationItemAdded =
      RealtimeServerMessageType('ConversationItemAdded');

  /// Indicates a conversation item is complete.
  static const RealtimeServerMessageType conversationItemDone =
      RealtimeServerMessageType('ConversationItemDone');

  /// Indicates an error occurred while processing the request.
  static const RealtimeServerMessageType error =
      RealtimeServerMessageType('Error');

  @override
  bool operator ==(Object other) =>
      other is RealtimeServerMessageType &&
      value.toLowerCase() == other.value.toLowerCase();

  @override
  int get hashCode => value.toLowerCase().hashCode;

  @override
  String toString() => value;
}

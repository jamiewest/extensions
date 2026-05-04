import 'realtime_server_message.dart';
import 'realtime_server_message_type.dart';

/// Represents a real-time server message for output text and audio.
class OutputTextAudioRealtimeServerMessage extends RealtimeServerMessage {
  /// Initializes a new instance of the [OutputTextAudioRealtimeServerMessage]
  /// class for handling output text delta responses.
  ///
  /// Remarks: The `type` should be [OutputTextDelta], [OutputTextDone],
  /// [OutputAudioTranscriptionDelta], [OutputAudioTranscriptionDone],
  /// [OutputAudioDelta], or [OutputAudioDone].
  ///
  /// [type] The type of the real-time server response.
  OutputTextAudioRealtimeServerMessage(RealtimeServerMessageType type) {
    Type = type;
  }

  /// Gets or sets the index of the content part whose text has been updated.
  int? contentIndex;

  /// Gets or sets the text delta or final text content.
  ///
  /// Remarks: Populated for [OutputTextDelta], [OutputTextDone],
  /// [OutputAudioTranscriptionDelta], and [OutputAudioTranscriptionDone]
  /// messages. For audio messages ([OutputAudioDelta] and [OutputAudioDone]),
  /// use [Audio] instead.
  String? text;

  /// Gets or sets the Base64-encoded audio data delta or final audio content.
  ///
  /// Remarks: Populated for [OutputAudioDelta] messages. For [OutputAudioDone],
  /// this is typically `null` as the final audio is not included; use the
  /// accumulated deltas instead. For text content, use [Text] instead.
  String? audio;

  /// Gets or sets the ID of the item containing the content part whose text has
  /// been updated.
  String? itemId;

  /// Gets or sets the index of the output item in the response.
  int? outputIndex;

  /// Gets or sets the ID of the response.
  ///
  /// Remarks: May be `null` for providers that do not natively track response
  /// lifecycle.
  String? responseId;
}

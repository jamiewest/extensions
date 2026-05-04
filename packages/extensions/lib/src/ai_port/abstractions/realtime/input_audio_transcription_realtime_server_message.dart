import '../contents/error_content.dart';
import '../usage_details.dart';
import 'realtime_server_message.dart';
import 'realtime_server_message_type.dart';

/// Represents a real-time server message for input audio transcription.
///
/// Remarks: Used when having InputAudioTranscriptionCompleted,
/// InputAudioTranscriptionDelta, or InputAudioTranscriptionFailed response
/// types.
class InputAudioTranscriptionRealtimeServerMessage
    extends RealtimeServerMessage {
  /// Initializes a new instance of the
  /// [InputAudioTranscriptionRealtimeServerMessage] class.
  ///
  /// Remarks: The `type` parameter should be InputAudioTranscriptionCompleted,
  /// InputAudioTranscriptionDelta, or InputAudioTranscriptionFailed.
  ///
  /// [type] The type of the real-time server response.
  InputAudioTranscriptionRealtimeServerMessage(RealtimeServerMessageType type) {
    Type = type;
  }

  /// Gets or sets the index of the content part containing the audio.
  int? contentIndex;

  /// Gets or sets the ID of the item containing the audio that is being
  /// transcribed.
  String? itemId;

  /// Gets or sets the transcription text of the audio.
  String? transcription;

  /// Gets or sets the transcription-specific usage, which is billed separately
  /// from the realtime model.
  ///
  /// Remarks: This usage reflects the cost of the speech-to-text transcription
  /// and is billed according to the ASR (Automatic Speech Recognition) model's
  /// pricing rather than the realtime model's pricing.
  UsageDetails? usage;

  /// Gets or sets the error content if an error occurred during transcription.
  ErrorContent? error;
}

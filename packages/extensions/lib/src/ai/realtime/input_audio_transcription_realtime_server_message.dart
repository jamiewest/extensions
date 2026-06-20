import 'package:extensions/annotations.dart';

import '../error_content.dart';
import '../usage_details.dart';
import 'realtime_server_message.dart';

/// A server message carrying input audio transcription results.
///
/// This is an experimental feature.
@Source(
  name: 'InputAudioTranscriptionRealtimeServerMessage.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class InputAudioTranscriptionRealtimeServerMessage
    extends RealtimeServerMessage {
  /// Creates a new [InputAudioTranscriptionRealtimeServerMessage] with the
  /// given [type].
  InputAudioTranscriptionRealtimeServerMessage(super.type);

  /// The index of the content part being transcribed.
  int? contentIndex;

  /// The ID of the item being transcribed.
  String? itemId;

  /// The transcription text.
  String? transcription;

  /// Usage details for the transcription.
  UsageDetails? usage;

  /// The error content, if transcription failed.
  ErrorContent? error;
}

import '../data_content.dart';
import 'realtime_client_message.dart';

/// A client message that appends audio to the input audio buffer.
///
/// This is an experimental feature.
class InputAudioBufferAppendRealtimeClientMessage
    extends RealtimeClientMessage {
  /// Creates a new [InputAudioBufferAppendRealtimeClientMessage] for the given
  /// [content].
  InputAudioBufferAppendRealtimeClientMessage(this.content);

  /// The audio content to append to the input buffer.
  DataContent content;
}

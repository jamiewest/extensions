import '../contents/data_content.dart';
import 'realtime_client_message.dart';

/// Represents a real-time message for appending audio buffer input.
class InputAudioBufferAppendRealtimeClientMessage
    extends RealtimeClientMessage {
  /// Initializes a new instance of the
  /// [InputAudioBufferAppendRealtimeClientMessage] class.
  ///
  /// [audioContent] The data content containing the audio buffer data to
  /// append.
  InputAudioBufferAppendRealtimeClientMessage(DataContent audioContent)
    : _content = Throw.ifNull(audioContent);

  DataContent _content;

  /// Gets or sets the audio content to append to the model audio buffer.
  ///
  /// Remarks: The content should include the audio buffer data that needs to be
  /// appended to the input audio buffer.
  DataContent content;
}

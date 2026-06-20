import 'package:extensions/annotations.dart';

import '../data_content.dart';
import 'realtime_client_message.dart';

/// A client message that appends audio to the input audio buffer.
///
/// This is an experimental feature.
@Source(
  name: 'InputAudioBufferAppendRealtimeClientMessage.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class InputAudioBufferAppendRealtimeClientMessage
    extends RealtimeClientMessage {
  /// Creates a new [InputAudioBufferAppendRealtimeClientMessage] for the given
  /// [content].
  InputAudioBufferAppendRealtimeClientMessage(this.content);

  /// The audio content to append to the input buffer.
  DataContent content;
}

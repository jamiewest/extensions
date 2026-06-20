import 'package:extensions/annotations.dart';

import 'realtime_client_message.dart';

/// A client message that commits the pending input audio buffer.
///
/// This is an experimental feature.
@Source(
  name: 'InputAudioBufferCommitRealtimeClientMessage.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class InputAudioBufferCommitRealtimeClientMessage
    extends RealtimeClientMessage {
  /// Creates a new [InputAudioBufferCommitRealtimeClientMessage].
  InputAudioBufferCommitRealtimeClientMessage();
}

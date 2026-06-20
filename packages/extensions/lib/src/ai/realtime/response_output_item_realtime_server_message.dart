import 'package:extensions/annotations.dart';

import 'realtime_conversation_item.dart';
import 'realtime_server_message.dart';

/// A server message describing an output item added to or completed within a
/// response.
///
/// This is an experimental feature.
@Source(
  name: 'ResponseOutputItemRealtimeServerMessage.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class ResponseOutputItemRealtimeServerMessage extends RealtimeServerMessage {
  /// Creates a new [ResponseOutputItemRealtimeServerMessage] with the given
  /// [type].
  ResponseOutputItemRealtimeServerMessage(super.type);

  /// The ID of the response.
  String? responseId;

  /// The index of the output item.
  int? outputIndex;

  /// The output conversation item.
  RealtimeConversationItem? item;
}

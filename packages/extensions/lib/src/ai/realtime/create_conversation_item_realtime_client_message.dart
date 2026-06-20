import 'package:extensions/annotations.dart';

import 'realtime_client_message.dart';
import 'realtime_conversation_item.dart';

/// A client message that creates a new conversation item.
///
/// This is an experimental feature.
@Source(
  name: 'CreateConversationItemRealtimeClientMessage.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class CreateConversationItemRealtimeClientMessage
    extends RealtimeClientMessage {
  /// Creates a new [CreateConversationItemRealtimeClientMessage] for [item].
  CreateConversationItemRealtimeClientMessage(this.item);

  /// The conversation item to create.
  RealtimeConversationItem item;
}

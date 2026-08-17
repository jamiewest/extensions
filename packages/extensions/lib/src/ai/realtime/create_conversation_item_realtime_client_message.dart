import 'realtime_client_message.dart';
import 'realtime_conversation_item.dart';

/// A client message that creates a new conversation item.
///
/// This is an experimental feature.
class CreateConversationItemRealtimeClientMessage
    extends RealtimeClientMessage {
  /// Creates a new [CreateConversationItemRealtimeClientMessage] for [item].
  CreateConversationItemRealtimeClientMessage(this.item);

  /// The conversation item to create.
  RealtimeConversationItem item;
}

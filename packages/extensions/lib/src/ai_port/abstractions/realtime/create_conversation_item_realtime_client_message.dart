import 'realtime_client_message.dart';
import 'realtime_conversation_item.dart';

/// Represents a real-time message for creating a conversation item.
class CreateConversationItemRealtimeClientMessage
    extends RealtimeClientMessage {
  /// Initializes a new instance of the
  /// [CreateConversationItemRealtimeClientMessage] class.
  ///
  /// [item] The conversation item to create.
  CreateConversationItemRealtimeClientMessage(RealtimeConversationItem item)
    : item = item,
      _item = Throw.ifNull(item);

  RealtimeConversationItem _item;

  /// Gets or sets the conversation item to create.
  RealtimeConversationItem item;
}

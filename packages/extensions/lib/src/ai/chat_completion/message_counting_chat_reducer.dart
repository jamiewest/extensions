import '../../system/threading/cancellation_token.dart';
import 'chat_message.dart';
import '../chat_reduction/chat_reducer.dart';

/// A chat reducer that keeps the most recent messages up to a target count.
///
/// System messages are always preserved. The reducer keeps the first
/// system message(s) and the most recent non-system messages.
class MessageCountingChatReducer extends ChatReducer {
  /// Creates a new [MessageCountingChatReducer].
  ///
  /// [targetCount] is the target number of messages to retain.
  MessageCountingChatReducer(this.targetCount) {
    if (targetCount < 1) {
      throw ArgumentError.value(
        targetCount,
        'targetCount',
        'Must be at least 1.',
      );
    }
  }

  /// The target number of messages to retain.
  final int targetCount;

  @override
  Future<List<ChatMessage>> reduce(
    List<ChatMessage> messages, {
    CancellationToken? cancellationToken,
  }) async {
    if (messages.length <= targetCount) {
      return messages;
    }

    // Take the last targetCount messages
    return messages.sublist(messages.length - targetCount);
  }
}

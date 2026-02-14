import 'package:extensions/system.dart';

import '../chat_completion/chat_message.dart';
import 'chat_reducer.dart';
import '../chat_completion/chat_role.dart';

/// A reducer that keeps the most recent messages up to a target count.
///
/// Leading system messages at the beginning of the conversation are
/// always preserved. The reducer keeps those system messages plus the
/// most recent non-system messages up to [targetCount].
///
/// This mirrors the extensions package's `MessageCountingChatReducer`
/// with the enhancement of preserving leading system messages.
///
/// ```dart
/// final reducer = MessageCountingReducer(10);
/// final reduced = await reducer.reduce(messages);
/// // reduced.length <= 10
/// ```
class MessageCountingReducer extends ChatReducer {
  /// Creates a new [MessageCountingReducer].
  ///
  /// [targetCount] is the maximum number of messages to retain
  /// (including preserved leading system messages). Must be at least 1.
  MessageCountingReducer(this.targetCount) {
    if (targetCount < 1) {
      throw ArgumentError.value(
        targetCount,
        'targetCount',
        'Must be at least 1.',
      );
    }
  }

  /// The maximum number of messages to retain.
  final int targetCount;

  @override
  Future<List<ChatMessage>> reduce(
    List<ChatMessage> messages, {
    CancellationToken? cancellationToken,
  }) async {
    if (messages.length <= targetCount) {
      return messages;
    }

    // Count leading system messages.
    var systemCount = 0;
    for (final msg in messages) {
      if (msg.role == ChatRole.system) {
        systemCount++;
      } else {
        break;
      }
    }

    // Keep leading system messages + most recent non-system messages.
    final keepFromEnd = targetCount - systemCount;
    if (keepFromEnd <= 0) {
      // Only room for system messages — return as many as fit.
      return messages.sublist(0, targetCount);
    }

    final systemMessages = messages.sublist(0, systemCount);
    final recentMessages = messages.sublist(messages.length - keepFromEnd);
    return [...systemMessages, ...recentMessages];
  }
}

import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_role.dart';
import '../abstractions/chat_reduction/chat_reducer.dart';
import '../abstractions/contents/function_call_content.dart';
import '../abstractions/contents/function_result_content.dart';

/// Provides a chat reducer that limits the number of non-system messages in a
/// conversation to a specified maximum count, preserving the most recent
/// messages and the first system message if present.
///
/// Remarks: This reducer is useful for scenarios where it is necessary to
/// constrain the size of a chat history, such as when preparing input for
/// models with context length limits. The reducer always includes the first
/// encountered system message, if any, and then retains up to the specified
/// number of the most recent non-system messages. Messages containing
/// function call or function result content are excluded from the reduced
/// output.
class MessageCountingChatReducer implements ChatReducer {
  /// Initializes a new instance of the [MessageCountingChatReducer] class.
  ///
  /// [targetCount] The maximum number of non-system messages to retain in the
  /// reduced output.
  const MessageCountingChatReducer(int targetCount) : _targetCount = Throw.ifLessThanOrEqual(targetCount, min: 0);

  final int _targetCount;

  @override
  Future<Iterable<ChatMessage>> reduce(
    Iterable<ChatMessage> messages,
    CancellationToken cancellationToken,
  ) {
    _ = Throw.ifNull(messages);
    return Task.fromResult(getReducedMessages(messages));
  }

  Iterable<ChatMessage> getReducedMessages(Iterable<ChatMessage> messages) {
    var systemMessage = null;
    var reducedMessages = new(capacity: _targetCount);
    for (final message in messages) {
      if (message.role == ChatRole.system) {
        systemMessage ??= message;
      } else if (!message.contents.any((m) => m is FunctionCallContent or FunctionResultContent)) {
        if (reducedMessages.count >= _targetCount) {
          _ = reducedMessages.dequeue();
        }
        reducedMessages.enqueue(message);
      }
    }
    if (systemMessage != null) {
      yield systemMessage;
    }
    while (reducedMessages.count > 0) {
      yield reducedMessages.dequeue();
    }
  }
}

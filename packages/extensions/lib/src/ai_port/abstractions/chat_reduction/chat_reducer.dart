import '../chat_completion/chat_message.dart';

/// Represents a reducer capable of shrinking the size of a list of chat
/// messages.
abstract class ChatReducer {
  /// Reduces the size of a list of chat messages.
  ///
  /// Returns: The new list of messages.
  ///
  /// [messages] The messages to reduce.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests.
  Future<Iterable<ChatMessage>> reduce(
    Iterable<ChatMessage> messages,
    CancellationToken cancellationToken,
  );
}

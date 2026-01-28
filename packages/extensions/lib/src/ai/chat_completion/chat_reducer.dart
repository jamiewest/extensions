import '../../system/threading/cancellation_token.dart';
import 'chat_message.dart';

/// Reduces a list of chat messages (e.g. for context window
/// management).
///
/// This is an experimental feature.
abstract class ChatReducer {
  /// Reduces the given [messages].
  Future<List<ChatMessage>> reduce(
    List<ChatMessage> messages, {
    CancellationToken? cancellationToken,
  });
}

import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../chat_completion/chat_message.dart';

/// Reduces a list of chat messages (e.g. for context window
/// management).
///
/// This is an experimental feature.
@Source(
  name: 'IChatReducer.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/ChatReduction/',
  commit: 'a144ceba8f9bc2241b86352f8e97ba68f82df217',
)
abstract class ChatReducer {
  /// Reduces the given [messages].
  Future<List<ChatMessage>> reduce(
    List<ChatMessage> messages, {
    CancellationToken? cancellationToken,
  });
}

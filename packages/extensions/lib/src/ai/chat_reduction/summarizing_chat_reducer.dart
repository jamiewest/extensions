import '../../system/threading/cancellation_token.dart';
import '../chat_completion/chat_client.dart';
import '../chat_completion/chat_message.dart';
import '../chat_completion/chat_options.dart';
import '../chat_completion/chat_role.dart';
import 'chat_reducer.dart';

/// A [ChatReducer] that summarizes older messages using a [ChatClient].
///
/// When the message count exceeds [targetCount], older messages are condensed
/// into a single system message while the most recent messages are preserved.
///
/// ```dart
/// final reducer = SummarizingChatReducer(
///   chatClient: client,
///   targetCount: 20,
/// );
/// final reduced = await reducer.reduce(messages);
/// ```
class SummarizingChatReducer extends ChatReducer {
  /// Creates a new [SummarizingChatReducer].
  SummarizingChatReducer({
    required this.chatClient,
    this.targetCount = 20,
    this.threshold = 5,
    this.summarizationPrompt =
        'Summarize the conversation so far in a concise paragraph.',
  });

  /// The chat client used to generate summaries.
  final ChatClient chatClient;

  /// Message count threshold that triggers summarization.
  final int targetCount;

  /// Number of messages beyond [targetCount] allowed before summarizing.
  final int threshold;

  /// The prompt used to request a summary from the model.
  final String summarizationPrompt;

  @override
  Future<List<ChatMessage>> reduce(
    List<ChatMessage> messages, {
    CancellationToken? cancellationToken,
  }) async {
    if (messages.length <= targetCount + threshold) return messages;

    final keepCount = targetCount ~/ 2;
    final toSummarize = messages.sublist(0, messages.length - keepCount);
    final toKeep = messages.sublist(messages.length - keepCount);

    final summarizeMessages = [
      ...toSummarize,
      ChatMessage.fromText(ChatRole.user, summarizationPrompt),
    ];

    final response = await chatClient.getResponse(
      messages: summarizeMessages,
      options: ChatOptions(),
      cancellationToken: cancellationToken,
    );

    return [
      ChatMessage.fromText(
        ChatRole.system,
        'Summary of earlier conversation: ${response.text}',
      ),
      ...toKeep,
    ];
  }
}

import '../../system/threading/cancellation_token.dart';
import 'chat_client.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_reducer.dart';
import 'chat_role.dart';

/// A [ChatReducer] that summarizes older messages using a [ChatClient].
///
/// When the message count exceeds [maxMessageCount], older messages
/// are summarized into a single system message while preserving
/// the most recent messages.
///
/// This is an experimental feature.
class SummarizingChatReducer extends ChatReducer {
  /// Creates a new [SummarizingChatReducer].
  ///
  /// [chatClient] is used to generate summaries.
  /// [maxMessageCount] is the threshold above which summarization occurs.
  /// [summarizationPrompt] is the prompt used to request a summary.
  SummarizingChatReducer({
    required this.chatClient,
    this.maxMessageCount = 20,
    this.summarizationPrompt =
        'Summarize the conversation so far in a concise paragraph.',
  });

  /// The chat client used to generate summaries.
  final ChatClient chatClient;

  /// The maximum number of messages before summarization is triggered.
  final int maxMessageCount;

  /// The prompt used to request a summary from the model.
  final String summarizationPrompt;

  @override
  Future<List<ChatMessage>> reduce(
    List<ChatMessage> messages, {
    CancellationToken? cancellationToken,
  }) async {
    if (messages.length <= maxMessageCount) return messages;

    // Determine how many messages to keep and how many to summarize.
    final keepCount = maxMessageCount ~/ 2;
    final toSummarize = messages.sublist(0, messages.length - keepCount);
    final toKeep = messages.sublist(messages.length - keepCount);

    // Build a summarization request.
    final summarizeMessages = [
      ...toSummarize,
      ChatMessage.fromText(ChatRole.user, summarizationPrompt),
    ];

    final response = await chatClient.getChatResponse(
      messages: summarizeMessages,
      options: ChatOptions(),
      cancellationToken: cancellationToken,
    );

    final summary = response.text;

    return [
      ChatMessage.fromText(
        ChatRole.system,
        'Summary of earlier conversation: $summary',
      ),
      ...toKeep,
    ];
  }
}

import 'package:extensions/system.dart';

import '../chat_completion/chat_client.dart';
import '../chat_completion/chat_message.dart';
import '../chat_completion/chat_options.dart';
import 'chat_reducer.dart';
import '../chat_completion/chat_role.dart';

/// A reducer that summarizes older messages using an [InferenceClient].
///
/// When the message count exceeds [maxMessageCount], older messages
/// are summarized into a single system message while preserving the
/// most recent messages.
///
/// This mirrors the extensions package's `SummarizingChatReducer`.
///
/// ```dart
/// final reducer = SummarizingChatReducer(
///   inferenceClient: client,
///   maxMessageCount: 20,
/// );
/// final reduced = await reducer.reduce(messages);
/// ```
class SummarizingChatReducer extends ChatReducer {
  final String _summaryKey = '__summary__';
  final String _defaultSummarizationPrompt = '''
    **Generate a clear and complete summary of the entire conversation in no more than five sentences.**

    The summary must always:
    - Reflect contributions from both the user and the assistant
    - Preserve context to support ongoing dialogue
    - Incorporate any previously provided summary
    - Emphasize the most relevant and meaningful points

    The summary must never:
    - Offer critique, correction, interpretation, or speculation
    - Highlight errors, misunderstandings, or judgments of accuracy
    - Comment on events or ideas not present in the conversation
    - Omit any details included in an earlier summary
  ''';

  /// Creates a new [SummarizingReducer].
  ///
  /// [inferenceClient] is used to generate summaries.
  /// [maxMessageCount] is the threshold above which summarization occurs.
  /// [summarizationPrompt] is the prompt used to request a summary.
  SummarizingChatReducer({
    required this.chatClient,
    this.targetCount = 20,
    this.summarizationPrompt =
        'Summarize the conversation so far in a concise paragraph.',
  });

  /// The chat client used to generate summaries.
  final ChatClient chatClient;

  /// The maximum number of messages before summarization is triggered.
  final int targetCount;

  /// The number of messages allowed beyond [targetCount] before summarization is
  /// triggered. Must be greater than or equal to 0 if specified.
  final int threshold;

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

    final response = await chatClient.getResponse(
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

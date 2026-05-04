import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_role.dart';
import '../abstractions/chat_reduction/chat_reducer.dart';
import '../abstractions/contents/ai_content.dart';
import '../abstractions/contents/function_call_content.dart';
import '../abstractions/contents/function_result_content.dart';
import '../abstractions/contents/input_request_content.dart';
import '../abstractions/contents/input_response_content.dart';

/// Provides functionality to reduce a collection of chat messages into a
/// summarized form.
///
/// Remarks: This reducer is useful for scenarios where it is necessary to
/// constrain the size of a chat history, such as when preparing input for
/// models with context length limits. The reducer automatically summarizes
/// older messages when the conversation exceeds a specified length,
/// preserving context while reducing message count. The reducer maintains
/// system messages and excludes messages containing function call or function
/// result content from summarization.
class SummarizingChatReducer implements ChatReducer {
  /// Initializes a new instance of the [SummarizingChatReducer] class with the
  /// specified chat client, target count, and optional threshold count.
  ///
  /// [chatClient] The chat client used to interact with the chat system. Cannot
  /// be `null`.
  ///
  /// [targetCount] The target number of messages to retain after summarization.
  /// Must be greater than 0.
  ///
  /// [threshold] The number of messages allowed beyond `targetCount` before
  /// summarization is triggered. Must be greater than or equal to 0 if
  /// specified.
  const SummarizingChatReducer(
    ChatClient chatClient,
    int targetCount,
    int? threshold,
  ) :
      _chatClient = Throw.ifNull(chatClient),
      _targetCount = Throw.ifLessThanOrEqual(targetCount, min: 0),
      _thresholdCount = Throw.ifLessThan(threshold ?? 0, min: 0, nameof(threshold));

  final ChatClient _chatClient;

  final int _targetCount;

  final int _thresholdCount;

  /// Gets or sets the prompt text used for summarization.
  String summarizationPrompt = DefaultSummarizationPrompt;

  @override
  Future<Iterable<ChatMessage>> reduce(
    Iterable<ChatMessage> messages,
    CancellationToken cancellationToken,
  ) async  {
    _ = Throw.ifNull(messages);
    var summarizedConversation = SummarizedConversation.fromChatMessages(messages);
    var indexOfFirstMessageToKeep = summarizedConversation.findIndexOfFirstMessageToKeep(
      _targetCount,
      _thresholdCount,
    );
    if (indexOfFirstMessageToKeep > 0) {
      summarizedConversation = await summarizedConversation.resummarizeAsync(
                _chatClient,
                indexOfFirstMessageToKeep,
                summarizationPrompt,
                cancellationToken);
    }
    return summarizedConversation.toChatMessages();
  }
}
/// Represents a conversation with an optional summary.
class SummarizedConversation {
  /// Represents a conversation with an optional summary.
  const SummarizedConversation(
    String? summary,
    ChatMessage? systemMessage,
    List<ChatMessage> unsummarizedMessages,
  );

  /// Creates a [SummarizedConversation] from a list of chat messages.
  static SummarizedConversation fromChatMessages(Iterable<ChatMessage> messages) {
    var summary = null;
    var systemMessage = null;
    var unsummarizedMessages = List<ChatMessage>();
    for (final message in messages) {
      if (message.role == ChatRole.system) {
        systemMessage ??= message;
      } else {
        var summaryValue;
        if (message.additionalProperties?.tryGetValue<String>(SummaryKey) == true) {
          unsummarizedMessages.clear();
          summary = summaryValue;
        } else {
          unsummarizedMessages.add(message);
        }
      }
    }
    return new(summary, systemMessage, unsummarizedMessages);
  }

  /// Performs summarization by calling the chat client and updating the
  /// conversation state.
  Future<SummarizedConversation> resummarize(
    ChatClient chatClient,
    int indexOfFirstMessageToKeep,
    String summarizationPrompt,
    CancellationToken cancellationToken,
  ) async  {
    Debug.assertValue(
      indexOfFirstMessageToKeep > 0,
      "Expected positive index for first message to keep.",
    );
    var summarizerChatMessages = toSummarizerChatMessages(
      indexOfFirstMessageToKeep,
      summarizationPrompt,
    );
    var response = await chatClient.getResponseAsync(
      summarizerChatMessages,
      cancellationToken: cancellationToken,
    );
    var newSummary = response.text;
    var lastSummarizedMessage = unsummarizedMessages[indexOfFirstMessageToKeep - 1];
    var additionalProperties = lastSummarizedMessage.additionalProperties ??= [];
    additionalProperties[SummaryKey] = newSummary;
    var newUnsummarizedMessages = unsummarizedMessages.skip(indexOfFirstMessageToKeep).toList();
    return summarizedConversation(newSummary, systemMessage, newUnsummarizedMessages);
  }

  /// Determines the index of the first message to keep (not summarize) based on
  /// target and threshold counts.
  int findIndexOfFirstMessageToKeep(int targetCount, int thresholdCount, ) {
    var earliestAllowedIndex = unsummarizedMessages.count - thresholdCount - targetCount;
    if (earliestAllowedIndex <= 0) {
      return 0;
    }
    var indexOfFirstMessageToKeep = unsummarizedMessages.count - targetCount;
    while (indexOfFirstMessageToKeep > 0) {
      if (!unsummarizedMessages[indexOfFirstMessageToKeep - 1].contents.any(IsToolRelatedContent)) {
        break;
      }
      indexOfFirstMessageToKeep--;
    }
    for (var i = indexOfFirstMessageToKeep; i >= earliestAllowedIndex; i--) {
      if (unsummarizedMessages[i].role == ChatRole.user) {
        return i;
      }
    }
    return indexOfFirstMessageToKeep;
  }

  /// Converts the summarized conversation back into a collection of chat
  /// messages.
  Iterable<ChatMessage> toChatMessages() {
    if (systemMessage != null) {
      yield systemMessage;
    }
    if (summary != null) {
      yield chatMessage(ChatRole.assistant, summary);
    }
    for (final message in unsummarizedMessages) {
      yield message;
    }
  }

  /// Returns whether the given [AIContent] relates to tool calling
  /// capabilities.
  ///
  /// Remarks: This method returns `true` for content types whose meaning
  /// depends on other related [AIContent] instances in the conversation, such
  /// as function calls that require corresponding results, or other tool
  /// interactions that span multiple messages. Such content should be kept
  /// together during summarization.
  static bool isToolRelatedContent(AContent content) {
    return content
            is FunctionCallContent
            or FunctionResultContent
            or InputRequestContent
            or InputResponseContent;
  }

  /// Builds the list of messages to send to the chat client for summarization.
  Iterable<ChatMessage> toSummarizerChatMessages(
    int indexOfFirstMessageToKeep,
    String summarizationPrompt,
  ) {
    if (summary != null) {
      yield chatMessage(ChatRole.assistant, summary);
    }
    for (var i = 0; i < indexOfFirstMessageToKeep; i++) {
      var message = unsummarizedMessages[i];
      if (!message.contents.any(IsToolRelatedContent)) {
        yield message;
      }
    }
    yield chatMessage(ChatRole.system, summarizationPrompt);
  }
}

import '../ai_content.dart';
import 'chat_message.dart';
import 'chat_response.dart';
import 'chat_response_update.dart';
import 'chat_role.dart';

/// Provides extension methods for combining [ChatResponseUpdate] instances
/// into a [ChatResponse].
extension ChatResponseUpdatesExtensions on Iterable<ChatResponseUpdate> {
  /// Combines the updates into a single [ChatResponse].
  ChatResponse toChatResponse() {
    final accumulator = ChatResponseAccumulator();
    for (final update in this) {
      accumulator.add(update);
    }
    return accumulator.response;
  }
}

/// Provides extension methods for combining a stream of
/// [ChatResponseUpdate] instances into a [ChatResponse].
extension ChatResponseUpdatesStreamExtensions on Stream<ChatResponseUpdate> {
  /// Drains the stream and combines the updates into a single
  /// [ChatResponse].
  Future<ChatResponse> toChatResponse() async {
    final accumulator = ChatResponseAccumulator();
    await for (final update in this) {
      accumulator.add(update);
    }
    return accumulator.response;
  }
}

/// Provides extension methods for appending response messages to a
/// message list, such as a conversation history.
extension ChatMessageListExtensions on List<ChatMessage> {
  /// Adds all of the messages from [response] into this list.
  void addMessagesFromResponse(ChatResponse response) =>
      addAll(response.messages);

  /// Converts [updates] into [ChatMessage] instances and adds them to
  /// this list.
  ///
  /// Message boundaries are determined the same way as
  /// [ChatResponseUpdatesExtensions.toChatResponse], including coalescing
  /// contiguous content where applicable.
  void addMessagesFromUpdates(Iterable<ChatResponseUpdate> updates) {
    if (updates.isEmpty) {
      return;
    }
    addMessagesFromResponse(updates.toChatResponse());
  }

  /// Converts a single [update] into a [ChatMessage] and adds it to
  /// this list.
  ///
  /// If the update has no content, or all of its content is excluded by
  /// [filter], no message is added.
  void addMessagesFromUpdate(
    ChatResponseUpdate update, {
    bool Function(AIContent content)? filter,
  }) {
    final contents = filter == null
        ? update.contents
        : update.contents.where(filter).toList();
    if (contents.isNotEmpty) {
      add(
        ChatMessage(
          role: update.role ?? ChatRole.assistant,
          contents: contents,
          authorName: update.authorName,
          createdAt: update.createdAt,
          rawRepresentation: update.rawRepresentation,
          additionalProperties: update.additionalProperties,
        ),
      );
    }
  }

  /// Drains [updates], converts them into [ChatMessage] instances, and
  /// adds them to this list.
  Future<void> addMessagesFromStream(Stream<ChatResponseUpdate> updates) async {
    addMessagesFromResponse(await updates.toChatResponse());
  }
}

/// Incrementally folds [ChatResponseUpdate]s into a [ChatResponse].
///
/// This API supports infrastructure and is not intended to be used directly;
/// use the `toChatResponse` extensions instead.
class ChatResponseAccumulator {
  /// The response accumulated so far.
  final ChatResponse response = ChatResponse();

  ChatMessage? _currentMessage;

  /// Folds [update] into [response].
  void add(ChatResponseUpdate update) {
    if (_needsNewMessage(update)) {
      _currentMessage = ChatMessage(
        role: update.role ?? ChatRole.assistant,
        authorName: update.authorName,
        contents: [],
      );

      _currentMessage!.messageId = update.messageId;
      _currentMessage!.createdAt = update.createdAt;
      _currentMessage!.rawRepresentation = update.rawRepresentation;
      response.messages.add(_currentMessage!);
    }

    if (update.contents.isNotEmpty) {
      _currentMessage ??= ChatMessage(
        role: update.role ?? ChatRole.assistant,
        authorName: update.authorName,
        contents: [],
      );
      _currentMessage!.contents.addAll(update.contents);
    }

    if (update.responseId != null && update.responseId!.isNotEmpty) {
      response.responseId = update.responseId;
    }
    if (update.conversationId != null) {
      response.conversationId = update.conversationId;
    }
    if (response.createdAt == null && update.createdAt != null) {
      response.createdAt = update.createdAt;
    }
    if (update.finishReason != null) {
      response.finishReason = update.finishReason;
    }
    if (update.modelId != null) {
      response.modelId = update.modelId;
    }
    if (update.usage != null) {
      response.usage = update.usage;
    }
    if (update.continuationToken != null) {
      response.continuationToken = update.continuationToken;
    }
    if (update.rawRepresentation != null) {
      response.rawRepresentation = update.rawRepresentation;
    }
  }

  bool _needsNewMessage(ChatResponseUpdate update) {
    final currentMessage = _currentMessage;
    if (currentMessage == null) {
      return true;
    }

    if (_hasText(update.authorName) &&
        _hasText(currentMessage.authorName) &&
        update.authorName != currentMessage.authorName) {
      return true;
    }

    if (_hasText(update.messageId) &&
        _hasText(currentMessage.messageId) &&
        update.messageId != currentMessage.messageId) {
      return true;
    }

    return update.role != null && update.role != currentMessage.role;
  }

  static bool _hasText(String? value) => value != null && value.isNotEmpty;
}

// Source: https://github.com/dotnet/extensions/blob/main/src/Libraries/Microsoft.Extensions.AI.Abstractions/ChatCompletion/ChatResponse.cs

import '../additional_properties_dictionary.dart';
import 'chat_finish_reason.dart';
import 'chat_message.dart';
import 'chat_response_update.dart';
import '../response_continuation_token.dart';
import '../text_content.dart';
import '../usage_details.dart';

/// Represents the response to a chat request.
///
/// A [ChatResponse] provides one or more response messages and metadata
/// about the response. A typical response will contain a single message,
/// however a response might contain multiple messages in a variety of
/// scenarios. For example, if automatic function calling is employed,
/// such that a single request to a chat client might actually generate
/// multiple round-trips to an inner chat client it uses, all of the
/// involved messages might be surfaced as part of the final
/// [ChatResponse].
class ChatResponse {
  /// Creates a new [ChatResponse].
  ChatResponse({
    List<ChatMessage>? messages,
    this.responseId,
    this.conversationId,
    this.modelId,
    this.createdAt,
    this.finishReason,
    this.usage,
    this.continuationToken,
    this.rawRepresentation,
    this.additionalProperties,
  }) : messages = messages ?? [];

  /// Creates a [ChatResponse] with a single message.
  ChatResponse.fromMessage(ChatMessage message)
      : messages = [message],
        responseId = null,
        conversationId = null,
        modelId = null,
        createdAt = null,
        finishReason = null,
        usage = null,
        continuationToken = null,
        rawRepresentation = null,
        additionalProperties = null;

  /// The response messages.
  final List<ChatMessage> messages;

  /// A unique identifier for the response.
  String? responseId;

  /// A conversation state identifier.
  String? conversationId;

  /// The model that generated this response.
  String? modelId;

  /// When the response was created.
  DateTime? createdAt;

  /// The reason the response finished being generated.
  ChatFinishReason? finishReason;

  /// Usage details for the request/response.
  UsageDetails? usage;

  /// A token to resume an interrupted response.
  ResponseContinuationToken? continuationToken;

  /// The underlying implementation-specific object.
  Object? rawRepresentation;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets concatenated text from the last message's [TextContent]
  /// items.
  String get text {
    if (messages.isEmpty) return '';
    return messages.last.text;
  }

  /// Converts this response into a list of [ChatResponseUpdate]s.
  List<ChatResponseUpdate> toChatResponseUpdates() {
    final updates = <ChatResponseUpdate>[];

    for (final message in messages) {
      updates.add(
        ChatResponseUpdate(
          role: message.role,
          authorName: message.authorName,
          contents: message.contents,
          responseId: responseId,
          conversationId: conversationId,
          modelId: modelId,
          createdAt: createdAt,
          additionalProperties: additionalProperties,
        ),
      );
    }

    if (updates.isNotEmpty) {
      updates.last.finishReason = finishReason;
    }

    return updates;
  }

  @override
  String toString() => text;
}

import '../additional_properties_dictionary.dart';
import '../ai_content.dart';
import '../response_continuation_token.dart';
import '../text_content.dart';
import '../usage_details.dart';
import 'chat_finish_reason.dart';
import 'chat_role.dart';

/// Represents a single streaming update to a chat response.
class ChatResponseUpdate {
  /// Creates a new [ChatResponseUpdate].
  ChatResponseUpdate({
    this.role,
    this.authorName,
    List<AIContent>? contents,
    this.rawRepresentation,
    this.additionalProperties,
    this.responseId,
    this.messageId,
    this.conversationId,
    this.createdAt,
    this.finishReason,
    this.modelId,
    this.continuationToken,
    this.usage,
  }) : contents = contents ?? [];

  /// Creates a [ChatResponseUpdate] with text content.
  ChatResponseUpdate.fromText(this.role, String text)
      : contents = [TextContent(text)],
        authorName = null,
        rawRepresentation = null,
        additionalProperties = null,
        responseId = null,
        messageId = null,
        conversationId = null,
        createdAt = null,
        finishReason = null,
        modelId = null,
        continuationToken = null,
        usage = null;

  /// The role of the update author.
  ChatRole? role;

  /// The name of the update author.
  String? authorName;

  /// The content items in this update.
  final List<AIContent> contents;

  /// The underlying implementation-specific object.
  Object? rawRepresentation;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// The parent response identifier.
  String? responseId;

  /// The message group identifier.
  String? messageId;

  /// The conversation identifier.
  String? conversationId;

  /// When this update was created.
  DateTime? createdAt;

  /// The reason the response finished being generated.
  ChatFinishReason? finishReason;

  /// The model that generated this update.
  String? modelId;

  /// A token to resume an interrupted response.
  ResponseContinuationToken? continuationToken;

  /// Usage details.
  UsageDetails? usage;

  /// Gets concatenated text from all [TextContent] items.
  String get text =>
      contents.whereType<TextContent>().map((c) => c.text).join();

  /// Creates a deep copy of this update.
  ChatResponseUpdate clone() => ChatResponseUpdate(
        role: role,
        authorName: authorName,
        contents: List<AIContent>.of(contents),
        rawRepresentation: rawRepresentation,
        additionalProperties:
            additionalProperties != null ? Map.of(additionalProperties!) : null,
        responseId: responseId,
        messageId: messageId,
        conversationId: conversationId,
        createdAt: createdAt,
        finishReason: finishReason,
        modelId: modelId,
        continuationToken: continuationToken,
        usage: usage,
      );

  @override
  String toString() => text;
}

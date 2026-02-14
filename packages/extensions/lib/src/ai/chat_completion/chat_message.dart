import 'package:extensions/annotations.dart';

import '../additional_properties_dictionary.dart';
import '../ai_content.dart';
import '../text_content.dart';
import 'chat_role.dart';

/// Represents a chat message used by a chat client.
@Source(
  name: 'ChatMessage.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/ChatCompletion/',
  commit: 'b56aec451afe841d1865da4c9cb45fd5a379a519',
)
class ChatMessage {
  /// Creates a new [ChatMessage].
  ChatMessage({
    required this.role,
    List<AIContent>? contents,
    this.authorName,
    this.createdAt,
    this.messageId,
    this.rawRepresentation,
    this.additionalProperties,
  }) : contents = contents ?? [];

  /// Creates a [ChatMessage] with [TextContent] from a string.
  ChatMessage.fromText(this.role, String text, {this.authorName})
      : contents = [TextContent(text)],
        createdAt = null,
        messageId = null,
        rawRepresentation = null,
        additionalProperties = null;

  /// The role of the message author.
  final ChatRole role;

  /// The name of the message author.
  String? authorName;

  /// The content items of the message.
  final List<AIContent> contents;

  /// When the message was created.
  DateTime? createdAt;

  /// A unique identifier for the message.
  String? messageId;

  /// The underlying implementation-specific object.
  Object? rawRepresentation;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets concatenated text from all [TextContent] items.
  String get text =>
      contents.whereType<TextContent>().map((c) => c.text).join();

  /// Creates a deep copy of this message.
  ChatMessage clone() => ChatMessage(
        role: role,
        contents: List<AIContent>.of(contents),
        authorName: authorName,
        createdAt: createdAt,
        messageId: messageId,
        rawRepresentation: rawRepresentation,
        additionalProperties:
            additionalProperties != null ? Map.of(additionalProperties!) : null,
      );

  @override
  String toString() => text;
}

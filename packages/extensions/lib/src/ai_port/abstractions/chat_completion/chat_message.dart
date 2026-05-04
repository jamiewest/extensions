import '../contents/ai_content.dart';
import '../contents/text_content.dart';
import 'chat_client.dart';
import 'chat_role.dart';

/// Represents a chat message used by an [ChatClient].
class ChatMessage {
  /// Initializes a new instance of the [ChatMessage] class.
  ///
  /// [role] The role of the author of the message.
  ///
  /// [contents] The contents for this message.
  ChatMessage({ChatRole? role = null, String? content = null, List<AContent>? contents = null, }) : role = role, _contents = contents;

  List<AContent>? _contents;

  String? _authorName;

  /// Gets or sets the name of the author of the message.
  String? authorName;

  /// Gets or sets a timestamp for the chat message.
  DateTime? createdAt;

  /// Gets or sets the role of the author of the message.
  ChatRole role = ChatRole.User;

  /// Gets or sets the chat message content items.
  List<AContent> contents;

  /// Gets or sets the ID of the chat message.
  String? messageId;

  /// Gets or sets the raw representation of the chat message from an underlying
  /// implementation.
  ///
  /// Remarks: If a [ChatMessage] is created to represent some underlying object
  /// from another object model, this property can be used to store that
  /// original object. This can be useful for debugging or for enabling a
  /// consumer to access the underlying object model if needed.
  Object? rawRepresentation;

  /// Gets or sets any additional properties associated with the message.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets a [AIContent] object to display in the debugger display.
  final AContent? contentForDebuggerDisplay;

  /// Clones the [ChatMessage] to a new [ChatMessage] instance.
  ///
  /// Remarks: This is a shallow clone. The returned instance is different from
  /// the original, but all properties refer to the same objects as the
  /// original.
  ///
  /// Returns: A shallow clone of the original message object.
  ChatMessage clone() {
    return new()
        {
            additionalProperties = additionalProperties,
            _authorName = _authorName,
            _contents = _contents,
            createdAt = createdAt,
            rawRepresentation = rawRepresentation,
            role = role,
            messageId = messageId,
        };
  }

  /// Gets the text of this message.
  ///
  /// Remarks: This property concatenates the text of all [TextContent] objects
  /// in [Contents].
  String get text {
    return contents.concatText();
  }

  @override
  String toString() {
    return text;
  }

  /// Gets an indication for the debugger display of whether there's more
  /// content.
  String get ellipsesForDebuggerDisplay {
    return _contents is { Count: > 1 } ? ", ..." : string.empty;
  }
}

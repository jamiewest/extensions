import '../chat_completion/chat_role.dart';
import '../contents/ai_content.dart';

/// Represents a real-time conversation item.
///
/// Remarks: This class is used to encapsulate the details of a real-time item
/// that can be inserted into a conversation, or sent as part of a real-time
/// response creation process.
class RealtimeConversationItem {
  /// Initializes a new instance of the [RealtimeConversationItem] class.
  ///
  /// [contents] The contents of the conversation item.
  ///
  /// [id] The ID of the conversation item.
  ///
  /// [role] The role of the conversation item.
  RealtimeConversationItem(
    List<AContent> contents, {
    String? id = null,
    ChatRole? role = null,
  }) : id = id,
       role = role,
       contents = contents;

  /// Gets or sets the ID of the conversation item.
  ///
  /// Remarks: This ID can be null in case passing Function or MCP content where
  /// the ID is not required. The Id only needed of having contents representing
  /// a user, system, or assistant message with contents like text, audio, image
  /// or similar.
  String? id;

  /// Gets or sets the role of the conversation item.
  ///
  /// Remarks: The role not used in case of Function or MCP content. The role
  /// only needed of having contents representing a user, system, or assistant
  /// message with contents like text, audio, image or similar.
  ChatRole? role;

  /// Gets or sets the content of the conversation item.
  List<AContent> contents;

  /// Gets or sets the raw representation of the conversation item. This can be
  /// used to hold the original data structure received from or sent to the
  /// provider.
  Object? rawRepresentation;
}

import 'package:extensions/annotations.dart';

import '../ai_content.dart';
import '../chat_completion/chat_role.dart';

/// Represents an item in a real-time conversation.
///
/// This is an experimental feature.
@Source(
  name: 'RealtimeConversationItem.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class RealtimeConversationItem {
  /// Creates a new [RealtimeConversationItem] with the given [contents].
  RealtimeConversationItem(this.contents, {this.id, this.role});

  /// The optional identifier of the conversation item.
  String? id;

  /// The optional role of the conversation item author.
  ChatRole? role;

  /// The content items that make up the conversation item.
  List<AIContent> contents;

  /// The raw representation of the conversation item from an underlying
  /// implementation.
  Object? rawRepresentation;
}

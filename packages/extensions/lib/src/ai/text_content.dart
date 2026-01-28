import 'ai_content.dart';

/// Represents text content in a chat message.
class TextContent extends AIContent {
  /// Creates a new [TextContent] with the given [text].
  TextContent(this.text);

  /// The text value.
  final String text;

  @override
  String toString() => text;
}

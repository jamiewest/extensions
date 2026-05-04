import 'ai_content.dart';

/// Represents text content in a chat.
class TextContent extends AContent {
  /// Initializes a new instance of the [TextContent] class.
  ///
  /// [text] The text content.
  const TextContent(String? text) : text = text;

  /// Gets or sets the text content.
  String text;

  @override
  String toString() {
    return text;
  }

  String get debuggerDisplay {
    return 'text = \"${text}\"';
  }
}

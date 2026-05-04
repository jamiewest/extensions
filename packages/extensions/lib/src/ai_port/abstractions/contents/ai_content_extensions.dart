import '../chat_completion/chat_message.dart';
import 'ai_content.dart';
import 'text_content.dart';

/// Internal extensions for working with [AIContent].
extension AContentExtensions on Iterable<AContent> {
  /// Concatenates the text of all [TextContent] instances in the list.
String concatText({List<ChatMessage>? messages}) {
if (contents is ListAContent) {
    final list = contents as ListAContent;
    var count = list.count;
    switch (count) {
      case 0:
        return string.empty;
      case 1:
        return (list[0] as TextContent)?.text ?? string.empty;
      default:
        var builder = new();
        for (var i = 0; i < count; i++) {
          if (list[i] is TextContent) {
            final text = list[i] as TextContent;
            builder.append(text.text);
          }
        }
        return builder.toString();
    }
  }

return string.concat(contents.ofType<TextContent>());
 }
 }

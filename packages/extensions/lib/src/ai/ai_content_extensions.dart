import 'ai_content.dart';
import 'text_content.dart';

/// Extensions for working with collections of [AIContent].
extension AIContentExtensions on Iterable<AIContent> {
  /// Returns all items of type [T].
  Iterable<T> ofType<T extends AIContent>() => whereType<T>();

  /// Returns the first item of type [T], or `null` if none exists.
  T? firstOfTypeOrNull<T extends AIContent>() {
    for (final item in this) {
      if (item is T) return item;
    }
    return null;
  }

  /// Concatenates the text of all [TextContent] items.
  String concatText() => whereType<TextContent>().map((c) => c.text).join();
}

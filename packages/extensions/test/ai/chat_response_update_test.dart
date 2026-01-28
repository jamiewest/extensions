import 'package:extensions/ai.dart';
import 'package:test/test.dart';

void main() {
  group('ChatResponseUpdate', () {
    test('fromText creates text content', () {
      final update = ChatResponseUpdate.fromText(ChatRole.assistant, 'Hello');

      expect(update.role, ChatRole.assistant);
      expect(update.contents, hasLength(1));
      expect(update.text, 'Hello');
      expect(update.responseId, isNull);
    });

    test('text concatenates text contents', () {
      final update = ChatResponseUpdate(
        contents: [TextContent('One'), TextContent('Two')],
      );

      expect(update.text, 'OneTwo');
    });

    test('clone copies collections', () {
      final update = ChatResponseUpdate(
        role: ChatRole.user,
        contents: [TextContent('Hi')],
        additionalProperties: {'key': 'value'},
      );

      final clone = update.clone();

      expect(identical(clone.contents, update.contents), isFalse);
      expect(identical(clone.additionalProperties, update.additionalProperties),
          isFalse);

      clone.contents.add(TextContent(' there'));
      expect(update.contents, hasLength(1));

      clone.additionalProperties!['key'] = 'changed';
      expect(update.additionalProperties!['key'], 'value');
    });
  });
}

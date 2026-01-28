import 'dart:typed_data';

import 'package:extensions/ai.dart';
import 'package:test/test.dart';

void main() {
  group('ChatMessage', () {
    test('fromText creates text content', () {
      final message = ChatMessage.fromText(
        ChatRole.user,
        'Hello',
        authorName: 'Jamie',
      );

      expect(message.role, ChatRole.user);
      expect(message.authorName, 'Jamie');
      expect(message.contents, hasLength(1));
      expect(message.contents.first, isA<TextContent>());
      expect(message.text, 'Hello');
      expect(message.createdAt, isNull);
      expect(message.messageId, isNull);
    });

    test('text concatenates only text contents', () {
      final message = ChatMessage(
        role: ChatRole.user,
        contents: [
          TextContent('Hello'),
          DataContent(
            Uint8List.fromList([1, 2, 3]),
            mediaType: 'image/png',
          ),
          TextContent(' world'),
        ],
      );

      expect(message.text, 'Hello world');
    });

    test('clone copies collections', () {
      final message = ChatMessage(
        role: ChatRole.assistant,
        contents: [TextContent('Hi')],
        additionalProperties: {'key': 'value'},
      );

      final clone = message.clone();

      expect(identical(clone.contents, message.contents), isFalse);
      expect(
        identical(clone.additionalProperties, message.additionalProperties),
        isFalse,
      );

      clone.contents.add(TextContent(' there'));
      expect(message.contents, hasLength(1));

      clone.additionalProperties!['key'] = 'changed';
      expect(message.additionalProperties!['key'], 'value');
    });
  });
}

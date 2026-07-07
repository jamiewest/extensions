import 'package:extensions/ai.dart';
import 'package:test/test.dart';

void main() {
  group('toChatResponse', () {
    test('combines updates from a list into one message', () {
      final updates = [
        ChatResponseUpdate(
          role: ChatRole.assistant,
          contents: [TextContent('Hello')],
          responseId: 'r1',
          modelId: 'm1',
        ),
        ChatResponseUpdate(contents: [TextContent(', world')]),
      ];

      final response = updates.toChatResponse();

      expect(response.messages, hasLength(1));
      expect(response.text, equals('Hello, world'));
      expect(response.responseId, equals('r1'));
      expect(response.modelId, equals('m1'));
    });

    test('starts a new message when the role changes', () {
      final updates = [
        ChatResponseUpdate(
          role: ChatRole.assistant,
          contents: [TextContent('a')],
        ),
        ChatResponseUpdate(role: ChatRole.tool, contents: [TextContent('b')]),
      ];

      final response = updates.toChatResponse();

      expect(response.messages, hasLength(2));
    });

    test('drains a stream into one response', () async {
      final stream = Stream.fromIterable([
        ChatResponseUpdate(
          role: ChatRole.assistant,
          contents: [TextContent('chunk1 ')],
        ),
        ChatResponseUpdate(contents: [TextContent('chunk2')]),
      ]);

      final response = await stream.toChatResponse();

      expect(response.text, equals('chunk1 chunk2'));
    });
  });
}

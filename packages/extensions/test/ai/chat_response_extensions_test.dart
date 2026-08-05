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

  group('addMessages', () {
    test('addMessagesFromResponse appends all response messages', () {
      final history = [ChatMessage.fromText(ChatRole.user, 'hi')];
      final response = ChatResponse(
        messages: [
          ChatMessage.fromText(ChatRole.assistant, 'hello'),
          ChatMessage.fromText(ChatRole.assistant, 'again'),
        ],
      );

      history.addMessagesFromResponse(response);

      expect(history, hasLength(3));
      expect(history[1].text, equals('hello'));
      expect(history[2].text, equals('again'));
    });

    test('addMessagesFromUpdates coalesces updates into messages', () {
      final history = <ChatMessage>[];
      final updates = [
        ChatResponseUpdate(
          role: ChatRole.assistant,
          contents: [TextContent('Hello')],
        ),
        ChatResponseUpdate(contents: [TextContent(', world')]),
      ];

      history.addMessagesFromUpdates(updates);

      expect(history, hasLength(1));
      expect(history.single.text, equals('Hello, world'));
    });

    test('addMessagesFromUpdates with no updates adds nothing', () {
      final history = <ChatMessage>[];

      history.addMessagesFromUpdates(const []);

      expect(history, isEmpty);
    });

    test('addMessagesFromUpdate maps update members onto the message', () {
      final history = <ChatMessage>[];
      final createdAt = DateTime.utc(2026, 1, 2);
      final update = ChatResponseUpdate(
        role: ChatRole.tool,
        authorName: 'author',
        createdAt: createdAt,
        contents: [TextContent('result')],
      );

      history.addMessagesFromUpdate(update);

      expect(history, hasLength(1));
      expect(history.single.role, equals(ChatRole.tool));
      expect(history.single.authorName, equals('author'));
      expect(history.single.createdAt, equals(createdAt));
      expect(history.single.text, equals('result'));
    });

    test('addMessagesFromUpdate defaults the role to assistant', () {
      final history = <ChatMessage>[];

      history.addMessagesFromUpdate(
        ChatResponseUpdate(contents: [TextContent('x')]),
      );

      expect(history.single.role, equals(ChatRole.assistant));
    });

    test('addMessagesFromUpdate skips fully filtered updates', () {
      final history = <ChatMessage>[];
      final update = ChatResponseUpdate(
        role: ChatRole.assistant,
        contents: [TextContent('drop me')],
      );

      history.addMessagesFromUpdate(
        update,
        filter: (content) => content is! TextContent,
      );

      expect(history, isEmpty);
    });

    test('addMessagesFromStream drains and appends', () async {
      final history = <ChatMessage>[];
      final stream = Stream.fromIterable([
        ChatResponseUpdate(
          role: ChatRole.assistant,
          contents: [TextContent('a')],
        ),
        ChatResponseUpdate(contents: [TextContent('b')]),
      ]);

      await history.addMessagesFromStream(stream);

      expect(history, hasLength(1));
      expect(history.single.text, equals('ab'));
    });
  });
}

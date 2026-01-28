import 'package:extensions/ai.dart';
import 'package:test/test.dart';

void main() {
  group('ChatResponse', () {
    test('text returns last message text', () {
      final response = ChatResponse(messages: [
        ChatMessage.fromText(ChatRole.user, 'Hi'),
        ChatMessage.fromText(ChatRole.assistant, 'Hello'),
      ]);

      expect(response.text, 'Hello');
    });

    test('text returns empty string when no messages', () {
      final response = ChatResponse();
      expect(response.text, '');
    });

    test('fromMessage creates response with single message', () {
      final message = ChatMessage.fromText(ChatRole.user, 'Ping');
      final response = ChatResponse.fromMessage(message);

      expect(response.messages, hasLength(1));
      expect(response.messages.first, message);
      expect(response.responseId, isNull);
      expect(response.finishReason, isNull);
    });

    test('toChatResponseUpdates maps messages and sets finish reason', () {
      final createdAt = DateTime(2024, 1, 1);
      final response = ChatResponse(
        messages: [
          ChatMessage.fromText(ChatRole.user, 'Hi'),
          ChatMessage.fromText(ChatRole.assistant, 'Hello'),
        ],
        responseId: 'resp-1',
        conversationId: 'conv-1',
        modelId: 'model-1',
        createdAt: createdAt,
        finishReason: ChatFinishReason.stop,
        additionalProperties: {'a': 1},
      );

      final updates = response.toChatResponseUpdates();

      expect(updates, hasLength(2));
      expect(updates.first.text, 'Hi');
      expect(updates.last.text, 'Hello');
      expect(updates.first.finishReason, isNull);
      expect(updates.last.finishReason, ChatFinishReason.stop);
      expect(updates.first.responseId, 'resp-1');
      expect(updates.first.conversationId, 'conv-1');
      expect(updates.first.modelId, 'model-1');
      expect(updates.first.createdAt, createdAt);
    });
  });
}

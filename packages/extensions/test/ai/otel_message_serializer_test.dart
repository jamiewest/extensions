import 'dart:convert';

import 'package:extensions/ai.dart';
import 'package:extensions/src/ai/common/otel_message_serializer.dart';
import 'package:test/test.dart';

void main() {
  group('OtelMessageSerializer', () {
    test('serializes text messages with roles and finish reason', () {
      final messages = [
        ChatMessage.fromText(ChatRole.system, 'be helpful'),
        ChatMessage.fromText(ChatRole.user, 'hi'),
        ChatMessage.fromText(ChatRole.assistant, 'hello'),
      ];

      final json = OtelMessageSerializer.serializeChatMessages(
        messages,
        finishReason: ChatFinishReason.stop,
      );
      final decoded = jsonDecode(json) as List<dynamic>;

      expect(decoded, hasLength(3));
      final system = decoded[0] as Map<String, dynamic>;
      expect(system['role'], 'system');
      expect(system['finish_reason'], 'stop');
      final parts = system['parts'] as List<dynamic>;
      final part = parts.single as Map<String, dynamic>;
      expect(part['type'], 'text');
      expect(part['content'], 'be helpful');
      expect((decoded[1] as Map<String, dynamic>)['role'], 'user');
      expect((decoded[2] as Map<String, dynamic>)['role'], 'assistant');
    });

    test('maps finish reasons to convention values', () {
      String reasonFor(ChatFinishReason reason) {
        final json = OtelMessageSerializer.serializeChatMessages(
          [ChatMessage.fromText(ChatRole.assistant, 'x')],
          finishReason: reason,
        );
        final decoded = jsonDecode(json) as List<dynamic>;
        final message = decoded.single as Map<String, dynamic>;
        return message['finish_reason'] as String;
      }

      expect(reasonFor(ChatFinishReason.length), 'length');
      expect(reasonFor(ChatFinishReason.contentFilter), 'content_filter');
      expect(reasonFor(ChatFinishReason.toolCalls), 'tool_call');
      expect(reasonFor(ChatFinishReason.stop), 'stop');
    });

    test('serializes function call and result parts', () {
      final messages = [
        ChatMessage(role: ChatRole.assistant, contents: [
          FunctionCallContent(
            callId: 'call-1',
            name: 'getWeather',
            arguments: {'city': 'Seattle'},
          ),
        ]),
        ChatMessage(role: ChatRole.tool, contents: [
          FunctionResultContent(callId: 'call-1', result: 'rainy'),
        ]),
      ];

      final json = OtelMessageSerializer.serializeChatMessages(messages);
      final decoded = jsonDecode(json) as List<dynamic>;

      final assistant = decoded[0] as Map<String, dynamic>;
      final callParts = assistant['parts'] as List<dynamic>;
      final call = callParts.single as Map<String, dynamic>;
      expect(call['type'], 'tool_call');
      expect(call['id'], 'call-1');
      expect(call['name'], 'getWeather');
      expect(call['arguments'], {'city': 'Seattle'});

      final tool = decoded[1] as Map<String, dynamic>;
      final resultParts = tool['parts'] as List<dynamic>;
      final result = resultParts.single as Map<String, dynamic>;
      expect(result['type'], 'tool_call_response');
      expect(result['id'], 'call-1');
      expect(result['response'], 'rainy');
    });

    test('serializes uri content with derived modality', () {
      final messages = [
        ChatMessage(role: ChatRole.user, contents: [
          UriContent(
            Uri.parse('https://example.com/cat.png'),
            mediaType: 'image/png',
          ),
        ]),
      ];

      final json = OtelMessageSerializer.serializeChatMessages(messages);
      final decoded = jsonDecode(json) as List<dynamic>;
      final message = decoded.single as Map<String, dynamic>;
      final parts = message['parts'] as List<dynamic>;
      final part = parts.single as Map<String, dynamic>;

      expect(part['type'], 'uri');
      expect(part['uri'], 'https://example.com/cat.png');
      expect(part['mime_type'], 'image/png');
      expect(part['modality'], 'image');
    });

    test('skips whitespace-only text parts', () {
      final messages = [
        ChatMessage(role: ChatRole.assistant, contents: [
          TextContent('   '),
          TextContent('real'),
        ]),
      ];

      final json = OtelMessageSerializer.serializeChatMessages(messages);
      final decoded = jsonDecode(json) as List<dynamic>;
      final message = decoded.single as Map<String, dynamic>;
      final parts = message['parts'] as List<dynamic>;

      expect(parts, hasLength(1));
      final part = parts.single as Map<String, dynamic>;
      expect(part['content'], 'real');
    });

    test('deriveModalityFromMediaType classifies top-level types', () {
      expect(
        OtelMessageSerializer.deriveModalityFromMediaType('image/png'),
        'image',
      );
      expect(
        OtelMessageSerializer.deriveModalityFromMediaType('audio/mpeg'),
        'audio',
      );
      expect(
        OtelMessageSerializer.deriveModalityFromMediaType('video/mp4'),
        'video',
      );
      expect(
        OtelMessageSerializer.deriveModalityFromMediaType('text/plain'),
        isNull,
      );
      expect(
        OtelMessageSerializer.deriveModalityFromMediaType(null),
        isNull,
      );
    });
  });
}

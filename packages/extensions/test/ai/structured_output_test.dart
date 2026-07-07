import 'package:extensions/ai.dart';
import 'package:extensions/src/system/exceptions/invalid_operation_exception.dart';
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

class _Recipe {
  _Recipe({required this.name, required this.minutes});

  factory _Recipe.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return _Recipe(
      name: map['name'] as String,
      minutes: map['minutes'] as int,
    );
  }

  final String name;
  final int minutes;
}

const _recipeSchema = <String, dynamic>{
  'type': 'object',
  'properties': {
    'name': {'type': 'string'},
    'minutes': {'type': 'integer'},
  },
  'required': ['name', 'minutes'],
};

class _ScriptedChatClient implements ChatClient {
  _ScriptedChatClient(this.reply);

  final String reply;
  Iterable<ChatMessage>? lastMessages;
  ChatOptions? lastOptions;

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    lastMessages = messages.toList();
    lastOptions = options;
    return ChatResponse.fromMessage(
      ChatMessage.fromText(ChatRole.assistant, reply),
    );
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      const Stream<ChatResponseUpdate>.empty();

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

void main() {
  group('getStructuredResponse', () {
    test('deserializes an object result', () async {
      final client = _ScriptedChatClient('{"name": "Toast", "minutes": 5}');

      final response = await client.getStructuredResponse<_Recipe>(
        messages: [ChatMessage.fromText(ChatRole.user, 'recipe?')],
        schema: _recipeSchema,
        fromJson: _Recipe.fromJson,
      );

      expect(response.result.name, equals('Toast'));
      expect(response.result.minutes, equals(5));
    });

    test('sets a JSON schema response format by default', () async {
      final client = _ScriptedChatClient('{"name": "Toast", "minutes": 5}');

      await client.getStructuredResponse<_Recipe>(
        messages: [ChatMessage.fromText(ChatRole.user, 'recipe?')],
        schema: _recipeSchema,
        fromJson: _Recipe.fromJson,
        schemaName: 'recipe',
      );

      final format =
          client.lastOptions?.responseFormat as ChatResponseFormatJsonSchema;
      expect(format.schema, equals(_recipeSchema));
      expect(format.schemaName, equals('recipe'));
      expect(client.lastMessages, hasLength(1));
    });

    test('augments the prompt when native schema format is disabled', () async {
      final client = _ScriptedChatClient('{"name": "Toast", "minutes": 5}');

      await client.getStructuredResponse<_Recipe>(
        messages: [ChatMessage.fromText(ChatRole.user, 'recipe?')],
        schema: _recipeSchema,
        fromJson: _Recipe.fromJson,
        useJsonSchemaResponseFormat: false,
      );

      expect(client.lastOptions?.responseFormat, ChatResponseFormat.json);
      expect(client.lastMessages, hasLength(2));
      expect(
        client.lastMessages!.last.text,
        contains('conforming to the following schema'),
      );
      expect(client.lastMessages!.last.text, contains('"minutes"'));
    });

    test('wraps non-object schemas and unwraps the data property', () async {
      final client = _ScriptedChatClient('{"data": [1, 2, 3]}');

      final response = await client.getStructuredResponse<List<int>>(
        messages: [ChatMessage.fromText(ChatRole.user, 'numbers?')],
        schema: const {
          'type': 'array',
          'items': {'type': 'integer'},
        },
        fromJson: (json) => (json as List<dynamic>).cast<int>(),
      );

      final format =
          client.lastOptions?.responseFormat as ChatResponseFormatJsonSchema;
      expect(format.schema['type'], equals('object'));
      expect(format.schema['required'], equals(['data']));
      expect(response.result, equals([1, 2, 3]));
    });

    test('result throws when the wrapper property is missing', () async {
      final client = _ScriptedChatClient('{"other": 1}');

      final response = await client.getStructuredResponse<List<int>>(
        messages: [ChatMessage.fromText(ChatRole.user, 'numbers?')],
        schema: const {'type': 'array'},
        fromJson: (json) => (json as List<dynamic>).cast<int>(),
      );

      expect(
        () => response.result,
        throwsA(isA<InvalidOperationException>()),
      );
      expect(response.tryGetResult(), isNull);
    });

    test('tryGetResult returns null on malformed JSON', () async {
      final client = _ScriptedChatClient('not json');

      final response = await client.getStructuredResponse<_Recipe>(
        messages: [ChatMessage.fromText(ChatRole.user, 'recipe?')],
        schema: _recipeSchema,
        fromJson: _Recipe.fromJson,
      );

      expect(response.tryGetResult(), isNull);
      expect(() => response.result, throwsFormatException);
    });

    test('only the first top-level JSON value is deserialized', () async {
      final client = _ScriptedChatClient(
        '{"name": "Toast", "minutes": 5}\n{"name": "Extra", "minutes": 1}',
      );

      final response = await client.getStructuredResponse<_Recipe>(
        messages: [ChatMessage.fromText(ChatRole.user, 'recipe?')],
        schema: _recipeSchema,
        fromJson: _Recipe.fromJson,
      );

      expect(response.result.name, equals('Toast'));
    });

    test('the raw JSON stays available on the response text', () async {
      final client = _ScriptedChatClient('{"name": "Toast", "minutes": 5}');

      final response = await client.getStructuredResponse<_Recipe>(
        messages: [ChatMessage.fromText(ChatRole.user, 'recipe?')],
        schema: _recipeSchema,
        fromJson: _Recipe.fromJson,
      );

      expect(response.text, contains('"Toast"'));
      expect(response.messages, hasLength(1));
    });
  });
}

import 'dart:convert';

import 'package:extensions/ai.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'helpers/verbatim_http_client.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  OpenAIChatClient makeClient(
    VerbatimHttpClient fakeHttp, {
    String modelId = 'gpt-4o-mini',
    Uri? endpoint,
  }) =>
      OpenAIChatClient(
        modelId,
        'test-key',
        options: OpenAIClientOptions(endpoint: endpoint, httpClient: fakeHttp),
      );

  String completionJson({
    String id = 'chatcmpl-1',
    String model = 'gpt-4o-mini',
    String content = 'Hello!',
    String finishReason = 'stop',
    int promptTokens = 10,
    int completionTokens = 5,
    int totalTokens = 15,
    String role = 'assistant',
  }) =>
      jsonEncode({
        'id': id,
        'object': 'chat.completion',
        'model': model,
        'choices': [
          {
            'index': 0,
            'message': {'role': role, 'content': content},
            'finish_reason': finishReason,
          },
        ],
        'usage': {
          'prompt_tokens': promptTokens,
          'completion_tokens': completionTokens,
          'total_tokens': totalTokens,
        },
      });

  // ---------------------------------------------------------------------------
  // Metadata
  // ---------------------------------------------------------------------------

  group('metadata', () {
    test('provider name is openai', () {
      final client = OpenAIChatClient('gpt-4o', 'key');
      expect(client.metadata.providerName, equals('openai'));
    });

    test('provider uri reflects custom endpoint', () {
      final endpoint = Uri.parse('http://localhost:1234/v1');
      final client = OpenAIChatClient(
        'gemma-4',
        'lm-studio',
        options: OpenAIClientOptions(endpoint: endpoint),
      );
      expect(client.metadata.providerUri, equals(endpoint));
    });

    test('default provider uri is openai api', () {
      final client = OpenAIChatClient('gpt-4o', 'key');
      expect(
        client.metadata.providerUri,
        equals(Uri.parse('https://api.openai.com/v1')),
      );
    });

    test('modelId is surfaced in metadata', () {
      final client = OpenAIChatClient('gpt-4o', 'key');
      expect(client.metadata.defaultModelId, equals('gpt-4o'));
    });
  });

  // ---------------------------------------------------------------------------
  // getService
  // ---------------------------------------------------------------------------

  group('getService', () {
    test('returns metadata when requested', () {
      final client = OpenAIChatClient('gpt-4o', 'key');
      expect(client.getService<ChatClientMetadata>(), isNotNull);
    });

    test('returns self when OpenAIChatClient requested', () {
      final client = OpenAIChatClient('gpt-4o', 'key');
      expect(client.getService<OpenAIChatClient>(), same(client));
    });

    test('returns null for unknown type', () {
      final client = OpenAIChatClient('gpt-4o', 'key');
      expect(client.getService<String>(), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Basic non-streaming
  // ---------------------------------------------------------------------------

  group('getResponse', () {
    test('returns text from assistant message', () async {
      final fakeHttp = VerbatimHttpClient(completionJson(content: 'Hi there!'));
      final client = makeClient(fakeHttp);

      final response = await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
      );

      expect(response.text, equals('Hi there!'));
    });

    test('populates modelId from response', () async {
      final fakeHttp = VerbatimHttpClient(completionJson(model: 'gpt-4o'));
      final client = makeClient(fakeHttp);

      final response = await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
      );

      expect(response.modelId, equals('gpt-4o'));
    });

    test('populates responseId', () async {
      final fakeHttp = VerbatimHttpClient(completionJson(id: 'chatcmpl-abc'));
      final client = makeClient(fakeHttp);

      final response = await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
      );

      expect(response.responseId, equals('chatcmpl-abc'));
    });

    test('maps finish_reason stop', () async {
      final fakeHttp = VerbatimHttpClient(completionJson(finishReason: 'stop'));
      final client = makeClient(fakeHttp);

      final response = await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
      );

      expect(response.finishReason, equals(ChatFinishReason.stop));
    });

    test('maps finish_reason length', () async {
      final fakeHttp =
          VerbatimHttpClient(completionJson(finishReason: 'length'));
      final client = makeClient(fakeHttp);

      final response = await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
      );

      expect(response.finishReason, equals(ChatFinishReason.length));
    });

    test('populates usage details', () async {
      final fakeHttp = VerbatimHttpClient(
        completionJson(
          promptTokens: 10,
          completionTokens: 20,
          totalTokens: 30,
        ),
      );
      final client = makeClient(fakeHttp);

      final response = await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
      );

      expect(response.usage?.inputTokenCount, equals(10));
      expect(response.usage?.outputTokenCount, equals(20));
      expect(response.usage?.totalTokenCount, equals(30));
    });

    test('throws on 4xx response', () async {
      final fakeHttp =
          ErrorHttpClient(statusCode: 401, body: '{"error":"Unauthorized"}');
      final client = OpenAIChatClient(
        'gpt-4o',
        'bad-key',
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      await expectLater(
        client.getResponse(
          messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
        ),
        throwsStateError,
      );
    });

    test('throws on 5xx response', () async {
      final fakeHttp = ErrorHttpClient(statusCode: 500);
      final client = OpenAIChatClient(
        'gpt-4o',
        'key',
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      await expectLater(
        client.getResponse(
          messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
        ),
        throwsStateError,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // ChatOptions mapping
  // ---------------------------------------------------------------------------

  group('ChatOptions mapping', () {
    test('temperature is sent', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      await makeClient(fakeHttp).getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'x')],
        options: ChatOptions(temperature: 0.5),
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      expect(body['temperature'], equals(0.5));
    });

    test('topP is sent as top_p', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      await makeClient(fakeHttp).getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'x')],
        options: ChatOptions(topP: 0.9),
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      expect(body['top_p'], equals(0.9));
    });

    test('maxOutputTokens is sent as max_tokens', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      await makeClient(fakeHttp).getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'x')],
        options: ChatOptions(maxOutputTokens: 100),
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      expect(body['max_tokens'], equals(100));
    });

    test('seed is sent', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      await makeClient(fakeHttp).getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'x')],
        options: ChatOptions(seed: 42),
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      expect(body['seed'], equals(42));
    });

    test('frequencyPenalty is sent as frequency_penalty', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      await makeClient(fakeHttp).getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'x')],
        options: ChatOptions(frequencyPenalty: 0.3),
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      expect(body['frequency_penalty'], equals(0.3));
    });

    test('presencePenalty is sent as presence_penalty', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      await makeClient(fakeHttp).getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'x')],
        options: ChatOptions(presencePenalty: 0.2),
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      expect(body['presence_penalty'], equals(0.2));
    });

    test('stopSequences is sent as stop', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      await makeClient(fakeHttp).getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'x')],
        options: ChatOptions(stopSequences: ['END', 'STOP']),
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      expect(body['stop'], equals(['END', 'STOP']));
    });

    test('modelId in options overrides constructor model', () async {
      final fakeHttp = VerbatimHttpClient(completionJson(model: 'gpt-4o'));
      await makeClient(fakeHttp, modelId: 'gpt-4o-mini').getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'x')],
        options: ChatOptions(modelId: 'gpt-4o'),
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      expect(body['model'], equals('gpt-4o'));
    });

    test('instructions sent as system message prepended', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      await makeClient(fakeHttp).getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
        options: ChatOptions(instructions: 'You are a helpful assistant.'),
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      final messages = body['messages'] as List<dynamic>;
      expect(messages.first['role'], equals('system'));
      expect(
        messages.first['content'],
        equals('You are a helpful assistant.'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Message roles
  // ---------------------------------------------------------------------------

  group('message roles', () {
    test('user role is preserved', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      await makeClient(fakeHttp).getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      final messages = body['messages'] as List<dynamic>;
      expect(messages.last['role'], equals('user'));
    });

    test('system role is preserved', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      await makeClient(fakeHttp).getResponse(
        messages: [
          ChatMessage.fromText(ChatRole.system, 'Be concise.'),
          ChatMessage.fromText(ChatRole.user, 'Hello'),
        ],
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      final messages = body['messages'] as List<dynamic>;
      expect(messages.first['role'], equals('system'));
    });

    test('assistant role in conversation is preserved', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      await makeClient(fakeHttp).getResponse(
        messages: [
          ChatMessage.fromText(ChatRole.user, 'Hello'),
          ChatMessage.fromText(ChatRole.assistant, 'Hi there!'),
          ChatMessage.fromText(ChatRole.user, 'Thanks'),
        ],
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      final messages = body['messages'] as List<dynamic>;
      expect(messages[1]['role'], equals('assistant'));
    });

    test('assistant role in response is parsed correctly', () async {
      final fakeHttp = VerbatimHttpClient(completionJson(role: 'assistant'));
      final response = await makeClient(fakeHttp).getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
      );
      expect(response.messages.first.role, equals(ChatRole.assistant));
    });
  });

  // ---------------------------------------------------------------------------
  // Custom endpoint (LM Studio scenario)
  // ---------------------------------------------------------------------------

  group('custom endpoint', () {
    test('request goes to configured endpoint', () async {
      final endpoint = Uri.parse('http://localhost:1234/v1');
      final fakeHttp = VerbatimHttpClient(completionJson());
      final client = OpenAIChatClient(
        'gemma-4',
        'lm-studio',
        options: OpenAIClientOptions(endpoint: endpoint, httpClient: fakeHttp),
      );

      await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
      );

      expect(
        fakeHttp.lastRequest?.url.toString(),
        equals('http://localhost:1234/v1/chat/completions'),
      );
    });

    test('api key is sent in Authorization header', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      final client = OpenAIChatClient(
        'gpt-4o',
        'sk-test-key',
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
      );

      expect(
        fakeHttp.lastRequest?.headers['Authorization'],
        equals('Bearer sk-test-key'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Streaming
  // ---------------------------------------------------------------------------

  group('getStreamingResponse', () {
    test('yields text from SSE chunks', () async {
      final sseLines = [
        'data: ${jsonEncode({
          'id': 'chatcmpl-1',
          'model': 'gpt-4o-mini',
          'choices': [
            {
              'delta': {'role': 'assistant', 'content': 'Hello'},
              'finish_reason': null,
            },
          ],
        })}',
        'data: ${jsonEncode({
          'id': 'chatcmpl-1',
          'model': 'gpt-4o-mini',
          'choices': [
            {
              'delta': {'content': ' world'},
              'finish_reason': null,
            },
          ],
        })}',
        'data: ${jsonEncode({
          'id': 'chatcmpl-1',
          'model': 'gpt-4o-mini',
          'choices': [
            {'delta': {}, 'finish_reason': 'stop'},
          ],
        })}',
        'data: [DONE]',
      ];

      final fakeHttp = StreamingHttpClient(sseLines);
      final client = OpenAIChatClient(
        'gpt-4o-mini',
        'key',
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      final updates = await client
          .getStreamingResponse(
            messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
          )
          .toList();

      expect(updates.map((u) => u.text).join(), equals('Hello world'));
    });

    test('stream=true is set in request body', () async {
      final fakeHttp = StreamingHttpClient(['data: [DONE]']);
      final client = OpenAIChatClient(
        'gpt-4o-mini',
        'key',
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      await client
          .getStreamingResponse(
            messages: [ChatMessage.fromText(ChatRole.user, 'x')],
          )
          .drain<void>();

      final req = fakeHttp.lastRequest as http.Request;
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['stream'], isTrue);
    });

    test('finish_reason surfaced on final update', () async {
      final sseLines = [
        'data: ${jsonEncode({
          'id': 'chatcmpl-1',
          'model': 'gpt-4o-mini',
          'choices': [
            {'delta': {'content': 'Hi'}, 'finish_reason': null},
          ],
        })}',
        'data: ${jsonEncode({
          'id': 'chatcmpl-1',
          'model': 'gpt-4o-mini',
          'choices': [
            {'delta': {}, 'finish_reason': 'stop'},
          ],
        })}',
        'data: [DONE]',
      ];

      final fakeHttp = StreamingHttpClient(sseLines);
      final client = OpenAIChatClient(
        'gpt-4o-mini',
        'key',
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      final updates = await client
          .getStreamingResponse(
            messages: [ChatMessage.fromText(ChatRole.user, 'x')],
          )
          .toList();

      final withReason = updates.where((u) => u.finishReason != null).toList();
      expect(withReason, isNotEmpty);
      expect(withReason.last.finishReason, equals(ChatFinishReason.stop));
    });
  });

  // ---------------------------------------------------------------------------
  // Response format
  // ---------------------------------------------------------------------------

  group('responseFormat', () {
    test('ChatResponseFormat.json sends json_object type', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      await makeClient(fakeHttp).getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'x')],
        options: ChatOptions(responseFormat: ChatResponseFormat.json),
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      expect(body['response_format'], equals({'type': 'json_object'}));
    });

    test('ChatResponseFormatJsonSchema sends json_schema type', () async {
      final fakeHttp = VerbatimHttpClient(completionJson());
      await makeClient(fakeHttp).getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'x')],
        options: ChatOptions(
          responseFormat: ChatResponseFormat.forJsonSchema(
            schema: {'type': 'object'},
            schemaName: 'mySchema',
          ),
        ),
      );
      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      final rf = body['response_format'] as Map<String, dynamic>;
      expect(rf['type'], equals('json_schema'));
      expect((rf['json_schema'] as Map)['name'], equals('mySchema'));
    });
  });

  // ---------------------------------------------------------------------------
  // Integration (skipped without OPENAI_API_KEY env var)
  // ---------------------------------------------------------------------------

  group('integration', () {
    test('makes a real chat request', () async {
      final client = _integrationClient();
      if (client == null) return;

      final response = await client.getResponse(
        messages: [
          ChatMessage.fromText(
            ChatRole.user,
            'Say "hello" and nothing else.',
          ),
        ],
      );
      expect(response.text.toLowerCase(), contains('hello'));
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}

OpenAIChatClient? _integrationClient() {
  // ignore: do_not_use_environment
  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  if (apiKey.isEmpty) return null;
  return OpenAIChatClient('gpt-4o-mini', apiKey);
}

import 'package:extensions/ai.dart';
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

class _CountingChatClient implements ChatClient {
  _CountingChatClient({required this.responses});

  final List<ChatResponse> responses;
  final List<List<ChatMessage>> calls = [];
  int _index = 0;

  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    calls.add(messages.toList());
    if (_index >= responses.length) {
      return ChatResponse();
    }
    return responses[_index++];
  }

  @override
  Stream<ChatResponseUpdate> getStreamingChatResponse({
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

class _MemoryCachingChatClient extends CachingChatClient {
  _MemoryCachingChatClient(super.innerClient);

  final Map<String, ChatResponse> cache = {};

  @override
  Future<ChatResponse?> getCachedResponse(String key) async => cache[key];

  @override
  Future<void> setCachedResponse(String key, ChatResponse response) async {
    cache[key] = response;
  }
}

class _TestFunction extends AIFunction {
  _TestFunction(this.nameToUse) : super(name: nameToUse);

  final String nameToUse;
  AIFunctionArguments? lastArguments;

  @override
  Future<Object?> invokeCore(
    AIFunctionArguments arguments, {
    CancellationToken? cancellationToken,
  }) async {
    lastArguments = arguments;
    return 'result';
  }
}

class _DummyTool extends AITool {
  _DummyTool(String name) : super(name: name);
}

void main() {
  group('CachingChatClient', () {
    test('returns cached response on subsequent call', () async {
      final response = ChatResponse.fromMessage(
        ChatMessage.fromText(ChatRole.assistant, 'cached'),
      );
      final inner = _CountingChatClient(responses: [response]);
      final client = _MemoryCachingChatClient(inner);

      final messages = [ChatMessage.fromText(ChatRole.user, 'hi')];
      final first = await client.getChatResponse(messages: messages);
      final second = await client.getChatResponse(messages: messages);

      expect(inner.calls, hasLength(1));
      expect(identical(first, second), isTrue);
    });

    test('getCacheKey uses message text and modelId', () {
      final client = _MemoryCachingChatClient(
        _CountingChatClient(responses: []),
      );
      final messages = [ChatMessage.fromText(ChatRole.user, 'hello')];
      final options = ChatOptions(modelId: 'model');

      final key = client.getCacheKey(messages, options);

      expect(key, 'user:hello|model:model');
    });
  });

  group('FunctionInvokingChatClient', () {
    test('invokes functions and sends tool results', () async {
      final callContent = FunctionCallContent(
        callId: 'call-1',
        name: 'tool',
        arguments: {'a': 1},
      );

      final responses = [
        ChatResponse.fromMessage(
          ChatMessage(
            role: ChatRole.assistant,
            contents: [callContent],
          ),
        ),
        ChatResponse.fromMessage(
          ChatMessage.fromText(ChatRole.assistant, 'final'),
        ),
      ];

      final inner = _CountingChatClient(responses: responses);
      final function = _TestFunction('tool');
      final client = FunctionInvokingChatClient(inner)
        ..additionalTools = [function];

      final response = await client.getChatResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'start')],
      );

      expect(response.text, 'final');
      expect(inner.calls, hasLength(2));

      final secondCall = inner.calls[1];
      expect(secondCall, hasLength(3));
      expect(
          secondCall[1].contents.whereType<FunctionCallContent>(), isNotEmpty);
      expect(secondCall[2].role, ChatRole.tool);
      final result = secondCall[2].contents.single as FunctionResultContent;
      expect(result.callId, 'call-1');
      expect(result.result, 'result');
      expect(function.lastArguments?['a'], 1);
    });

    test('terminates on unknown calls when configured', () async {
      final callContent = FunctionCallContent(
        callId: 'call-2',
        name: 'missing',
      );

      final responses = [
        ChatResponse.fromMessage(
          ChatMessage(
            role: ChatRole.assistant,
            contents: [callContent],
          ),
        ),
      ];

      final inner = _CountingChatClient(responses: responses);
      final client = FunctionInvokingChatClient(inner)
        ..additionalTools = [_DummyTool('other')]
        ..terminateOnUnknownCalls = true;

      final response = await client.getChatResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'start')],
      );

      expect(response.messages.last.contents, [callContent]);
      expect(inner.calls, hasLength(1));
    });
  });
}

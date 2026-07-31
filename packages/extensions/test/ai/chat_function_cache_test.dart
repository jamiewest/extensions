import 'package:extensions/ai.dart';
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

class _CountingChatClient implements ChatClient {
  _CountingChatClient({required this.responses});

  final List<ChatResponse> responses;
  final List<List<ChatMessage>> calls = [];
  int _index = 0;

  @override
  Future<ChatResponse> getResponse({
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

class _ThrowingFunction extends AIFunction {
  _ThrowingFunction(String name, this.error) : super(name: name);

  final Object error;

  @override
  Future<Object?> invokeCore(
    AIFunctionArguments arguments, {
    CancellationToken? cancellationToken,
  }) async =>
      throw error;
}

/// A client whose every turn requests one more call to each of
/// [functionNames], so the invocation loop can only end on its own limits.
class _EndlessToolCallChatClient implements ChatClient {
  _EndlessToolCallChatClient(this.functionNames);

  final List<String> functionNames;

  /// The tools advertised on each request, in order — used to verify that
  /// function declarations are withheld on the final iteration.
  final List<List<AITool>?> toolsPerCall = [];

  int _callId = 0;

  List<AIContent> _nextCalls(ChatOptions? options) {
    toolsPerCall.add(options?.tools);
    return [
      for (final name in functionNames)
        FunctionCallContent(callId: 'call-${++_callId}', name: name),
    ];
  }

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      ChatResponse.fromMessage(
        ChatMessage(role: ChatRole.assistant, contents: _nextCalls(options)),
      );

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    yield ChatResponseUpdate(
      role: ChatRole.assistant,
      contents: [TextContent('working on it')],
    );
    yield ChatResponseUpdate(
      role: ChatRole.assistant,
      contents: _nextCalls(options),
    );
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
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
      final first = await client.getResponse(messages: messages);
      final second = await client.getResponse(messages: messages);

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

      final response = await client.getResponse(
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

      final response = await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'start')],
      );

      expect(response.messages.last.contents, [callContent]);
      expect(inner.calls, hasLength(1));
    });

    test('withholds functions on the final iteration', () async {
      final function = _TestFunction('tool');
      final inner = _EndlessToolCallChatClient(['tool']);
      final client = FunctionInvokingChatClient(inner)
        ..maximumIterationsPerRequest = 2;

      final response = await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'start')],
        options: ChatOptions(
          tools: [function, _DummyTool('other')],
          toolMode: ChatToolMode.requireAny,
        ),
      );

      // Two rounds of invocation, then one last request that carries no
      // function declarations so the model has to answer.
      expect(inner.toolsPerCall, hasLength(3));
      expect(inner.toolsPerCall[0], contains(function));
      expect(inner.toolsPerCall[1], contains(function));
      expect(inner.toolsPerCall.last, isNot(contains(function)));

      // Non-function tools survive, and the response is still returned.
      expect(inner.toolsPerCall.last, [isA<_DummyTool>()]);
      expect(
          response.messages.last.contents.single, isA<FunctionCallContent>());
    });

    test('ends the stream at the iteration limit', () async {
      final inner = _EndlessToolCallChatClient(['tool']);
      final client = FunctionInvokingChatClient(inner)
        ..additionalTools = [_TestFunction('tool')]
        ..maximumIterationsPerRequest = 2;

      final text = await client
          .getStreamingResponse(
            messages: [ChatMessage.fromText(ChatRole.user, 'start')],
          )
          .map((u) => u.text)
          .where((t) => t.isNotEmpty)
          .toList();

      expect(text, ['working on it', 'working on it', 'working on it']);
    });

    test('rethrows a single tool failure past the error limit', () async {
      final error = StateError('tool failed');
      final inner = _EndlessToolCallChatClient(['tool']);
      final client = FunctionInvokingChatClient(inner)
        ..additionalTools = [_ThrowingFunction('tool', error)]
        ..maximumConsecutiveErrorsPerRequest = 1;

      await expectLater(
        client.getResponse(
          messages: [ChatMessage.fromText(ChatRole.user, 'start')],
        ),
        throwsA(same(error)),
      );
      // One failing round is tolerated; the second exceeds the limit.
      expect(inner.toolsPerCall, hasLength(2));
    });

    test('aggregates multiple tool failures past the error limit', () async {
      final inner = _EndlessToolCallChatClient(['first', 'second']);
      final client = FunctionInvokingChatClient(inner)
        ..additionalTools = [
          _ThrowingFunction('first', const FormatException('bad first')),
          _ThrowingFunction('second', const FormatException('bad second')),
        ]
        ..maximumConsecutiveErrorsPerRequest = 0;

      await expectLater(
        client.getResponse(
          messages: [ChatMessage.fromText(ChatRole.user, 'start')],
        ),
        throwsA(
          isA<AggregateException>().having(
            (e) => e.innerExceptions.map((x) => x.toString()).toList(),
            'innerExceptions',
            [contains('bad first'), contains('bad second')],
          ),
        ),
      );
    });
  });
}

import 'package:extensions/ai.dart';
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

class _StubChatClient implements ChatClient {
  _StubChatClient({
    Future<ChatResponse> Function()? onGetResponse,
    Stream<ChatResponseUpdate> Function()? onGetStreamingResponse,
  })  : _onGetResponse = onGetResponse,
        _onGetStreamingResponse = onGetStreamingResponse;

  final Future<ChatResponse> Function()? _onGetResponse;
  final Stream<ChatResponseUpdate> Function()? _onGetStreamingResponse;

  int responseCalls = 0;
  int streamCalls = 0;
  bool disposed = false;
  ChatOptions? lastOptions;

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    responseCalls++;
    lastOptions = options;
    return _onGetResponse!();
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    streamCalls++;
    lastOptions = options;
    return _onGetStreamingResponse!();
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() => disposed = true;
}

class _RecordingFailoverClient extends FailoverChatClient {
  _RecordingFailoverClient(this.clients);

  final List<ChatClient> clients;
  int selections = 0;
  final List<(FailoverChatClientAttempt, bool)> updates = [];

  @override
  Future<ChatClient> selectClient(
    RoutingContext context,
    CancellationToken? cancellationToken,
  ) async {
    final client = clients[selections];
    selections++;
    return client;
  }

  @override
  Future<void> onRoutingUpdate(
    RoutingContext context,
    FailoverChatClientAttempt attempt, {
    required bool isTerminal,
    CancellationToken? cancellationToken,
  }) async {
    updates.add((attempt, isTerminal));
  }
}

class _StubEmbeddingGenerator implements EmbeddingGenerator {
  _StubEmbeddingGenerator(this.vectors);

  final Map<String, List<double>> vectors;
  int calls = 0;
  bool disposed = false;

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    calls++;
    return GeneratedEmbeddings([
      for (final value in values)
        Embedding(vector: vectors[value] ?? (throw StateError('no $value'))),
    ]);
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() => disposed = true;
}

ChatResponse _response(String text) =>
    ChatResponse(messages: [ChatMessage.fromText(ChatRole.assistant, text)]);

List<ChatMessage> _userMessages(String text) =>
    [ChatMessage.fromText(ChatRole.user, text)];

void main() {
  group('RoutingChatClient', () {
    test('fromSelector invokes the selected client with cloned options',
        () async {
      final inner = _StubChatClient(
        onGetResponse: () async => _response('routed'),
      );
      final client = RoutingChatClient.fromSelector((context, ct) async {
        expect(context.messages, hasLength(1));
        return inner;
      });
      final options = ChatOptions(modelId: 'model-1');

      final response = await client.getResponse(
        messages: _userMessages('hi'),
        options: options,
      );

      expect(response.text, 'routed');
      expect(inner.responseCalls, 1);
      expect(inner.lastOptions, isNot(same(options)));
      expect(inner.lastOptions!.modelId, 'model-1');
    });

    test('fromSelector streams from the selected client', () async {
      final inner = _StubChatClient(
        onGetStreamingResponse: () => Stream.fromIterable([
          ChatResponseUpdate(contents: [TextContent('a')]),
          ChatResponseUpdate(contents: [TextContent('b')]),
        ]),
      );
      final client = RoutingChatClient.fromSelector((_, __) async => inner);

      final texts = await client
          .getStreamingResponse(messages: _userMessages('hi'))
          .map((update) => update.text)
          .toList();

      expect(texts, ['a', 'b']);
    });

    test('getService returns itself without a key and null with one', () {
      final client = RoutingChatClient.fromSelector(
        (_, __) async => _StubChatClient(),
      );

      expect(client.getService<RoutingChatClient>(), same(client));
      expect(client.getService<RoutingChatClient>(key: 'k'), isNull);
      expect(client.getService<String>(), isNull);
    });
  });

  group('FailoverChatClient', () {
    test('rejects a non-positive attempt limit', () {
      final client = _RecordingFailoverClient([]);

      expect(
        () => client.maximumAttemptsPerRequest = 0,
        throwsArgumentError,
      );
      client.maximumAttemptsPerRequest = 3;
      expect(client.maximumAttemptsPerRequest, 3);
    });

    test('reports a nonterminal failed attempt then a terminal success',
        () async {
      final failing = _StubChatClient(
        onGetResponse: () async => throw StateError('down'),
      );
      final succeeding = _StubChatClient(
        onGetResponse: () async => _response('ok'),
      );
      final client = _RecordingFailoverClient([failing, succeeding]);

      final response = await client.getResponse(messages: _userMessages('hi'));

      expect(response.text, 'ok');
      expect(client.updates, hasLength(2));

      final (firstAttempt, firstTerminal) = client.updates[0];
      expect(firstTerminal, isFalse);
      expect(firstAttempt.client, same(failing));
      expect(firstAttempt.exception, isA<StateError>());
      expect(firstAttempt.responseCompleted, isFalse);
      expect(firstAttempt.outputCommitted, isFalse);

      final (secondAttempt, secondTerminal) = client.updates[1];
      expect(secondTerminal, isTrue);
      expect(secondAttempt.client, same(succeeding));
      expect(secondAttempt.exception, isNull);
      expect(secondAttempt.responseCompleted, isTrue);
    });

    test('attempt limit makes the last permitted failure terminal', () async {
      final failing = _StubChatClient(
        onGetResponse: () async => throw StateError('down'),
      );
      final never = _StubChatClient(
        onGetResponse: () async => _response('unreachable'),
      );
      final client = _RecordingFailoverClient([failing, never])
        ..maximumAttemptsPerRequest = 1;

      await expectLater(
        client.getResponse(messages: _userMessages('hi')),
        throwsStateError,
      );
      expect(never.responseCalls, 0);
      expect(client.updates.single.$2, isTrue);
    });

    test('fails over when a stream errors before any update', () async {
      final failing = _StubChatClient(
        onGetStreamingResponse: () => Stream.error(StateError('stream down')),
      );
      final succeeding = _StubChatClient(
        onGetStreamingResponse: () => Stream.fromIterable([
          ChatResponseUpdate(contents: [TextContent('ok')]),
        ]),
      );
      final client = _RecordingFailoverClient([failing, succeeding]);

      final texts = await client
          .getStreamingResponse(messages: _userMessages('hi'))
          .map((update) => update.text)
          .toList();

      expect(texts, ['ok']);
      expect(client.updates, hasLength(2));
      final (firstAttempt, firstTerminal) = client.updates[0];
      expect(firstTerminal, isFalse);
      expect(firstAttempt.outputCommitted, isFalse);
      final (secondAttempt, secondTerminal) = client.updates[1];
      expect(secondTerminal, isTrue);
      expect(secondAttempt.responseCompleted, isTrue);
      expect(secondAttempt.outputCommitted, isTrue);
      expect(secondAttempt.timeToFirstUpdate, isNotNull);
    });

    test('propagates a failure after output was exposed', () async {
      Stream<ChatResponseUpdate> partial() async* {
        yield ChatResponseUpdate(contents: [TextContent('first')]);
        throw StateError('late failure');
      }

      final failing = _StubChatClient(onGetStreamingResponse: partial);
      final fallback = _StubChatClient(
        onGetStreamingResponse: () => Stream.fromIterable([
          ChatResponseUpdate(contents: [TextContent('unreachable')]),
        ]),
      );
      final client = _RecordingFailoverClient([failing, fallback]);

      final received = <String>[];
      Object? caught;
      try {
        await for (final update in client.getStreamingResponse(
          messages: _userMessages('hi'),
        )) {
          received.add(update.text);
        }
      } catch (e) {
        caught = e;
      }

      expect(received, ['first']);
      expect(caught, isA<StateError>());
      expect(fallback.streamCalls, 0);
      final (attempt, isTerminal) = client.updates.single;
      expect(isTerminal, isTrue);
      expect(attempt.outputCommitted, isTrue);
      expect(attempt.responseCompleted, isFalse);
    });
  });

  group('OrderedFailoverChatClient', () {
    test('requires at least one client', () {
      expect(() => OrderedFailoverChatClient([]), throwsArgumentError);
    });

    test('tries clients in order and returns the first success', () async {
      final first = _StubChatClient(
        onGetResponse: () async => throw StateError('one'),
      );
      final second = _StubChatClient(
        onGetResponse: () async => throw StateError('two'),
      );
      final third = _StubChatClient(
        onGetResponse: () async => _response('third'),
      );
      final client = OrderedFailoverChatClient([first, second, third]);

      final response = await client.getResponse(messages: _userMessages('hi'));

      expect(response.text, 'third');
      expect(first.responseCalls, 1);
      expect(second.responseCalls, 1);
      expect(third.responseCalls, 1);
    });

    test('rethrows the final failure when every client fails', () async {
      final first = _StubChatClient(
        onGetResponse: () async => throw StateError('one'),
      );
      final second = _StubChatClient(
        onGetResponse: () async => throw StateError('two'),
      );
      final client = OrderedFailoverChatClient([first, second]);

      await expectLater(
        client.getResponse(messages: _userMessages('hi')),
        throwsA(isA<StateError>().having((e) => e.message, 'message', 'two')),
      );
    });

    test('handles sequential requests independently', () async {
      var fail = true;
      final flaky = _StubChatClient(onGetResponse: () async {
        if (fail) {
          throw StateError('flaky');
        }
        return _response('flaky ok');
      });
      final backup = _StubChatClient(
        onGetResponse: () async => _response('backup'),
      );
      final client = OrderedFailoverChatClient([flaky, backup]);

      final first = await client.getResponse(messages: _userMessages('a'));
      fail = false;
      final second = await client.getResponse(messages: _userMessages('b'));

      expect(first.text, 'backup');
      expect(second.text, 'flaky ok');
    });

    test('dispose disposes inner clients unless leaveOpen', () {
      final a = _StubChatClient();
      final b = _StubChatClient();
      OrderedFailoverChatClient([a, b]).dispose();
      expect(a.disposed, isTrue);
      expect(b.disposed, isTrue);

      final c = _StubChatClient();
      OrderedFailoverChatClient([c], leaveOpen: true).dispose();
      expect(c.disposed, isFalse);
    });
  });

  group('SemanticRoutingChatClient', () {
    _StubEmbeddingGenerator generator() => _StubEmbeddingGenerator({
          'weather': [1.0, 0.0],
          'math': [0.0, 1.0],
          'what is the weather': [0.9, 0.1],
          'integrate x squared': [0.1, 0.9],
          'unrelated': [0.0, 0.0],
        });

    test('validates constructor arguments', () {
      final defaultClient = _StubChatClient();

      expect(
        () => SemanticRoutingChatClient(
          embeddingGenerator: generator(),
          clientProfiles: {},
          defaultClient: defaultClient,
        ),
        throwsArgumentError,
      );
      expect(
        () => SemanticRoutingChatClient(
          embeddingGenerator: generator(),
          clientProfiles: {
            _StubChatClient(): [' '],
          },
          defaultClient: defaultClient,
        ),
        throwsArgumentError,
      );
      expect(
        () => SemanticRoutingChatClient(
          embeddingGenerator: generator(),
          clientProfiles: {
            _StubChatClient(): ['weather'],
          },
          defaultClient: defaultClient,
          topK: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => SemanticRoutingChatClient(
          embeddingGenerator: generator(),
          clientProfiles: {
            _StubChatClient(): ['weather'],
          },
          defaultClient: defaultClient,
          scoreThreshold: 2,
        ),
        throwsArgumentError,
      );
    });

    test('routes to the most similar profiled client', () async {
      final weatherClient = _StubChatClient(
        onGetResponse: () async => _response('sunny'),
      );
      final mathClient = _StubChatClient(
        onGetResponse: () async => _response('42'),
      );
      final defaultClient = _StubChatClient(
        onGetResponse: () async => _response('default'),
      );
      final embeddings = generator();
      final client = SemanticRoutingChatClient(
        embeddingGenerator: embeddings,
        clientProfiles: {
          weatherClient: ['weather'],
          mathClient: ['math'],
        },
        defaultClient: defaultClient,
      );

      final weather = await client.getResponse(
        messages: _userMessages('what is the weather'),
      );
      final math = await client.getResponse(
        messages: _userMessages('integrate x squared'),
      );

      expect(weather.text, 'sunny');
      expect(math.text, '42');
      expect(defaultClient.responseCalls, 0);
    });

    test('builds the profile index once across requests', () async {
      final profiled = _StubChatClient(
        onGetResponse: () async => _response('profiled'),
      );
      final embeddings = generator();
      final client = SemanticRoutingChatClient(
        embeddingGenerator: embeddings,
        clientProfiles: {
          profiled: ['weather'],
        },
        defaultClient: _StubChatClient(),
      );

      await client.getResponse(messages: _userMessages('what is the weather'));
      await client.getResponse(messages: _userMessages('what is the weather'));

      // One call for the profile index, one per request query.
      expect(embeddings.calls, 3);
    });

    test('selects the default client when below the threshold', () async {
      final profiled = _StubChatClient(
        onGetResponse: () async => _response('profiled'),
      );
      final defaultClient = _StubChatClient(
        onGetResponse: () async => _response('default'),
      );
      final client = SemanticRoutingChatClient(
        embeddingGenerator: generator(),
        clientProfiles: {
          profiled: ['weather'],
        },
        defaultClient: defaultClient,
      );

      final response = await client.getResponse(
        messages: _userMessages('unrelated'),
      );

      expect(response.text, 'default');
      expect(profiled.responseCalls, 0);
    });

    test('selects the default client without a user message', () async {
      final profiled = _StubChatClient(
        onGetResponse: () async => _response('profiled'),
      );
      final defaultClient = _StubChatClient(
        onGetResponse: () async => _response('default'),
      );
      final client = SemanticRoutingChatClient(
        embeddingGenerator: generator(),
        clientProfiles: {
          profiled: ['weather'],
        },
        defaultClient: defaultClient,
      );

      final response = await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.system, 'be nice')],
      );

      expect(response.text, 'default');
    });

    test('dispose disposes owned clients and generator unless leaveOpen', () {
      final profiled = _StubChatClient();
      final defaultClient = _StubChatClient();
      final embeddings = generator();
      SemanticRoutingChatClient(
        embeddingGenerator: embeddings,
        clientProfiles: {
          profiled: ['weather'],
        },
        defaultClient: defaultClient,
      ).dispose();

      expect(profiled.disposed, isTrue);
      expect(defaultClient.disposed, isTrue);
      expect(embeddings.disposed, isTrue);

      final keptOpen = generator();
      final keptClient = _StubChatClient();
      SemanticRoutingChatClient(
        embeddingGenerator: keptOpen,
        clientProfiles: {
          keptClient: ['weather'],
        },
        defaultClient: _StubChatClient(),
        leaveOpen: true,
      ).dispose();

      expect(keptClient.disposed, isFalse);
      expect(keptOpen.disposed, isFalse);
    });
  });
}

import 'package:extensions/system.dart';
import 'package:extensions_genkit/extensions_genkit.dart';
import 'package:genkit/genkit.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ModelResponseChunk _textModelChunk(String text) => ModelResponseChunk(
      content: [TextPart(text: text)],
    );

ModelResponseChunk _toolModelChunk(String ref, String name) =>
    ModelResponseChunk(
      content: [
        ToolRequestPart(
          toolRequest: ToolRequest(ref: ref, name: name, input: {'x': 1}),
        ),
      ],
    );

Message _modelMessage(List<Part> content) =>
    Message(role: Role.model, content: content);

typedef _ChunkBuilder = List<ModelResponseChunk> Function();

/// Builds a [Genkit] instance with a synchronous fake model.
///
/// The model streams [chunks] (built lazily by [buildChunks]) then returns a
/// [ModelResponse] with the same content.
Genkit _fakeGenkit({required _ChunkBuilder buildChunks}) {
  final ai = Genkit(isDevEnv: false);
  ai.defineModel(
    name: 'test/model',
    fn: (request, ctx) async {
      final chunks = buildChunks();
      for (final chunk in chunks) {
        ctx.sendChunk(chunk);
      }
      final allContent = chunks.expand((c) => c.content).toList();
      return ModelResponse(
        message: _modelMessage(allContent),
        finishReason: FinishReason.stop,
      );
    },
  );
  return ai;
}

final _testModel = modelRef('test/model');

final class _PassthroughClient extends DelegatingChatClient {
  _PassthroughClient(super.innerClient);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GenkitChatClient.getStreamingResponse', () {
    late Genkit ai;
    late GenkitChatClient client;

    tearDown(() async {
      client.dispose();
      await ai.shutdown();
    });

    test('emits TextContent updates for text chunks', () async {
      ai = _fakeGenkit(
        buildChunks: () => [
          _textModelChunk('Hello, '),
          _textModelChunk('world!'),
        ],
      );
      client = GenkitChatClient(genkit: ai, model: _testModel);

      final updates = await client.getStreamingResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hi')],
      ).toList();

      expect(updates, hasLength(2));
      expect(
        (updates[0].contents.first as TextContent).text,
        'Hello, ',
      );
      expect(
        (updates[1].contents.first as TextContent).text,
        'world!',
      );
    });

    test('emits FunctionCallContent for tool-request chunks', () async {
      ai = _fakeGenkit(
        buildChunks: () => [
          _textModelChunk('thinking'),
          _toolModelChunk('call-1', 'myTool'),
        ],
      );
      client = GenkitChatClient(genkit: ai, model: _testModel);

      // Pass the matching AIFunction so the client sets returnToolRequests:true
      // and genkit does not try to execute the tool itself.
      final stubTool = AIFunctionFactory.create(
        name: 'myTool',
        callback: (args, {cancellationToken}) async => null,
      );

      final updates = await client.getStreamingResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Use myTool')],
        options: ChatOptions(tools: [stubTool]),
      ).toList();

      expect(updates, hasLength(2));
      final fc = updates[1].contents.first as FunctionCallContent;
      expect(fc.callId, 'call-1');
      expect(fc.name, 'myTool');
      expect(fc.arguments, {'x': 1});
    });

    test('suppresses updates whose contents are empty', () async {
      ai = _fakeGenkit(
        buildChunks: () => [
          ModelResponseChunk(content: [TextPart(text: '')]),
          _textModelChunk('real'),
        ],
      );
      client = GenkitChatClient(genkit: ai, model: _testModel);

      final updates = await client.getStreamingResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hi')],
      ).toList();

      expect(updates, hasLength(1));
      expect((updates.first.contents.first as TextContent).text, 'real');
    });

    test('stops early when cancellation token is pre-cancelled', () async {
      ai = _fakeGenkit(
        buildChunks: () => [_textModelChunk('x'), _textModelChunk('y')],
      );
      client = GenkitChatClient(genkit: ai, model: _testModel);

      final cts = CancellationTokenSource()..cancel();
      final updates = await client.getStreamingResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hi')],
        cancellationToken: CancellationToken.fromSource(cts),
      ).toList();

      expect(updates, isEmpty);
    });
  });

  group('GenkitChatClient.getResponse', () {
    late Genkit ai;
    late GenkitChatClient client;

    tearDown(() async {
      client.dispose();
      await ai.shutdown();
    });

    test('collects text chunks into a single ChatResponse', () async {
      ai = _fakeGenkit(
        buildChunks: () =>
            [_textModelChunk('Part one. '), _textModelChunk('Part two.')],
      );
      client = GenkitChatClient(genkit: ai, model: _testModel);

      final response = await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
      );

      expect(response.text, 'Part one. Part two.');
    });
  });

  group('GenkitChatClient.getService', () {
    late Genkit ai;
    late GenkitChatClient client;

    setUp(() {
      ai = _fakeGenkit(buildChunks: () => []);
      client = GenkitChatClient(genkit: ai, model: _testModel);
    });

    tearDown(() async {
      client.dispose();
      await ai.shutdown();
    });

    test('is a DelegatingChatClient', () {
      expect(client, isA<DelegatingChatClient>());
    });

    test('resolves itself', () {
      expect(client.getService<GenkitChatClient>(), same(client));
    });

    test('returns null for unregistered types', () {
      expect(client.getService<String>(), isNull);
    });

    test('resolves through wrapping middleware', () {
      final wrapper = _PassthroughClient(client);
      expect(wrapper.getService<GenkitChatClient>(), same(client));
    });
  });
}

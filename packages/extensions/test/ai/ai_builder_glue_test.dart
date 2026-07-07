import 'package:extensions/ai.dart';
import 'package:extensions/dependency_injection.dart';
import 'package:extensions/logging.dart';
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

class _TestChatClient implements ChatClient {
  Iterable<ChatMessage>? lastMessages;
  ChatOptions? lastOptions;

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    lastMessages = messages;
    lastOptions = options;
    return ChatResponse.fromMessage(
      ChatMessage.fromText(ChatRole.assistant, 'ok'),
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

class _TestEmbeddingGenerator implements EmbeddingGenerator {
  EmbeddingGenerationOptions? lastOptions;

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    lastOptions = options;
    return GeneratedEmbeddings(
      values.map((_) => Embedding(vector: [0.0])).toList(),
    );
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _TestImageGenerator implements ImageGenerator {
  @override
  Future<ImageGenerationResponse> generate({
    required ImageGenerationRequest request,
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      ImageGenerationResponse();

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _TestSpeechToTextClient implements SpeechToTextClient {
  @override
  Future<SpeechToTextResponse> getText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      SpeechToTextResponse();

  @override
  Stream<SpeechToTextResponse> getStreamingText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      const Stream.empty();

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _TestTextToSpeechClient implements TextToSpeechClient {
  @override
  Future<TextToSpeechResponse> getAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      TextToSpeechResponse();

  @override
  Stream<TextToSpeechResponseUpdate> getStreamingAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      const Stream.empty();

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _TestHostedFileClient implements HostedFileClient {
  @override
  Future<HostedFileContent> upload(
    Stream<List<int>> content, {
    String? mediaType,
    String? fileName,
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      HostedFileContent(fileId: 'id');

  @override
  Stream<List<int>> download(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      const Stream.empty();

  @override
  Future<HostedFileContent?> getFile(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      null;

  @override
  Stream<HostedFileContent> listFiles({
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      const Stream.empty();

  @override
  Future<bool> delete(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      false;

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _LastMessageReducer implements ChatReducer {
  @override
  Future<List<ChatMessage>> reduce(
    List<ChatMessage> messages, {
    CancellationToken? cancellationToken,
  }) async =>
      [messages.last];
}

void main() {
  group('ServiceCollection registration extensions', () {
    test('addEmbeddingGenerator registers and resolves', () {
      final services = ServiceCollection();

      final builder = services.addEmbeddingGenerator(
        (_) => _TestEmbeddingGenerator(),
      );

      expect(services.single.serviceType, EmbeddingGenerator);
      expect(services.single.lifetime, ServiceLifetime.singleton);
      expect(builder, isA<EmbeddingGeneratorBuilder>());
      final provider = services.buildServiceProvider();
      expect(
        provider.getRequiredService<EmbeddingGenerator>(),
        isA<_TestEmbeddingGenerator>(),
      );
    });

    test('addImageGenerator registers and resolves', () {
      final services = ServiceCollection()
        ..addImageGenerator((_) => _TestImageGenerator());

      expect(services.single.serviceType, ImageGenerator);
      final provider = services.buildServiceProvider();
      expect(
        provider.getRequiredService<ImageGenerator>(),
        isA<_TestImageGenerator>(),
      );
    });

    test('addSpeechToTextClient registers and resolves', () {
      final services = ServiceCollection()
        ..addSpeechToTextClient((_) => _TestSpeechToTextClient());

      expect(services.single.serviceType, SpeechToTextClient);
      final provider = services.buildServiceProvider();
      expect(
        provider.getRequiredService<SpeechToTextClient>(),
        isA<_TestSpeechToTextClient>(),
      );
    });

    test('addTextToSpeechClient registers and resolves', () {
      final services = ServiceCollection()
        ..addTextToSpeechClient((_) => _TestTextToSpeechClient());

      expect(services.single.serviceType, TextToSpeechClient);
      final provider = services.buildServiceProvider();
      expect(
        provider.getRequiredService<TextToSpeechClient>(),
        isA<_TestTextToSpeechClient>(),
      );
    });

    test('addTextToSpeechClient respects the provided lifetime', () {
      final services = ServiceCollection()
        ..addTextToSpeechClient(
          (_) => _TestTextToSpeechClient(),
          ServiceLifetime.scoped,
        );

      expect(services.single.lifetime, ServiceLifetime.scoped);
    });
  });

  group('asBuilder extensions', () {
    test('each client type produces a builder wrapping the client', () {
      final embedding = _TestEmbeddingGenerator();
      final image = _TestImageGenerator();
      final stt = _TestSpeechToTextClient();
      final tts = _TestTextToSpeechClient();
      final files = _TestHostedFileClient();

      expect(embedding.asBuilder().build(), same(embedding));
      expect(image.asBuilder().build(), same(image));
      expect(stt.asBuilder().build(), same(stt));
      expect(tts.asBuilder().build(), same(tts));
      expect(files.asBuilder().build(), same(files));
    });
  });

  group('useConfigureOptions', () {
    test('chat options are configured before each request', () async {
      final inner = _TestChatClient();
      final client = inner
          .asBuilder()
          .useConfigureOptions((options) => options..modelId = 'my-model')
          .build();

      await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'hi')],
      );

      expect(inner.lastOptions?.modelId, equals('my-model'));
    });

    test('embedding options are configured before each request', () async {
      final inner = _TestEmbeddingGenerator();
      final generator = inner
          .asBuilder()
          .useConfigureOptions((options) => options..modelId = 'embed-model')
          .build();

      await generator.generateEmbeddings(values: ['x']);

      expect(inner.lastOptions?.modelId, equals('embed-model'));
    });
  });

  group('useLogging', () {
    test('null logger factory short-circuits to the inner generator', () {
      final inner = _TestEmbeddingGenerator();
      final generator = inner
          .asBuilder()
          .useLogging(loggerFactory: NullLoggerFactory.instance)
          .build();

      expect(generator, same(inner));
    });

    test('a real logger factory wraps the generator', () {
      final factory = LoggerFactory.create((_) {});
      addTearDown(factory.dispose);
      final generator = _TestEmbeddingGenerator()
          .asBuilder()
          .useLogging(loggerFactory: factory)
          .build();

      expect(generator, isA<LoggingEmbeddingGenerator>());
    });

    test('text-to-speech and hosted file clients wrap unconditionally', () {
      final tts = _TestTextToSpeechClient().asBuilder().useLogging().build();
      final files = _TestHostedFileClient().asBuilder().useLogging().build();

      expect(tts, isA<LoggingTextToSpeechClient>());
      expect(files, isA<LoggingHostedFileClient>());
    });
  });

  group('chat pipeline extensions', () {
    test('useChatReducer reduces messages before forwarding', () async {
      final inner = _TestChatClient();
      final client =
          inner.asBuilder().useChatReducer(_LastMessageReducer()).build();

      await client.getResponse(messages: [
        ChatMessage.fromText(ChatRole.user, 'first'),
        ChatMessage.fromText(ChatRole.user, 'second'),
      ]);

      expect(inner.lastMessages, hasLength(1));
      expect(inner.lastMessages!.single.text, equals('second'));
    });

    test('useImageGeneration wraps with ImageGeneratingChatClient', () {
      final client = _TestChatClient()
          .asBuilder()
          .useImageGeneration(imageGenerator: _TestImageGenerator())
          .build();

      expect(client, isA<ImageGeneratingChatClient>());
    });

    test('useImageGeneration resolves the generator from services', () {
      final services = ServiceCollection();
      services.addSingletonInstance<ImageGenerator>(_TestImageGenerator());
      services.addChatClient((_) => _TestChatClient()).useImageGeneration();

      final provider = services.buildServiceProvider();
      expect(
        provider.getRequiredService<ChatClient>(),
        isA<ImageGeneratingChatClient>(),
      );
    });
  });
}

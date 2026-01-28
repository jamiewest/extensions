import 'dart:async';

import 'package:extensions/ai.dart';
import 'package:extensions/system.dart'
    show CancellationToken, OperationCanceledException;
import 'package:test/test.dart';

import '../logging/test_logger.dart';

class _ResponseChatClient implements ChatClient {
  _ResponseChatClient(this.response);

  final ChatResponse response;

  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      response;

  @override
  Stream<ChatResponseUpdate> getStreamingChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    yield ChatResponseUpdate.fromText(ChatRole.assistant, 'stream');
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _ThrowingChatClient implements ChatClient {
  _ThrowingChatClient(this.exception);

  final Exception exception;

  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    throw exception;
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

class _ThrowingStreamingChatClient implements ChatClient {
  _ThrowingStreamingChatClient(this.exception);

  final Exception exception;

  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      ChatResponse();

  @override
  Stream<ChatResponseUpdate> getStreamingChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      Stream<ChatResponseUpdate>.error(exception);

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _EmbeddingGenerator implements EmbeddingGenerator {
  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      GeneratedEmbeddings([
        Embedding(vector: [0.1, 0.2])
      ]);

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _ImageGenerator implements ImageGenerator {
  @override
  Future<ImageGenerationResponse> generate({
    required ImageGenerationRequest request,
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      ImageGenerationResponse(contents: [TextContent('image')]);

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _ThrowingImageGenerator implements ImageGenerator {
  _ThrowingImageGenerator(this.exception);

  final Exception exception;

  @override
  Future<ImageGenerationResponse> generate({
    required ImageGenerationRequest request,
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    throw exception;
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _SpeechToTextClient implements SpeechToTextClient {
  @override
  Future<SpeechToTextResponse> getText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      SpeechToTextResponse.fromText('text');

  @override
  Stream<SpeechToTextResponse> getStreamingText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    yield SpeechToTextResponse.fromText('stream');
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _ThrowingEmbeddingGenerator implements EmbeddingGenerator {
  _ThrowingEmbeddingGenerator(this.exception);

  final Exception exception;

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    throw exception;
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _ThrowingSpeechToTextClient implements SpeechToTextClient {
  _ThrowingSpeechToTextClient(this.exception);

  final Exception exception;

  @override
  Future<SpeechToTextResponse> getText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    throw exception;
  }

  @override
  Stream<SpeechToTextResponse> getStreamingText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      Stream<SpeechToTextResponse>.error(exception);

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

void main() {
  group('LoggingChatClient', () {
    test('logs invocation and completion', () async {
      final logger = TestLogger('chat');
      final inner = _ResponseChatClient(
        ChatResponse.fromMessage(
          ChatMessage.fromText(ChatRole.assistant, 'ok'),
        ),
      );
      final client = LoggingChatClient(inner, logger: logger);

      await client.getChatResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'hi')],
        options: ChatOptions(modelId: 'model'),
      );

      final messages = logger.loggedMessages.map((e) => e.message).toList();
      expect(messages, contains('getChatResponse invoked.'));
      expect(messages, contains('getChatResponse completed.'));
      expect(messages.any((m) => m.contains('Messages:')), isTrue);
      expect(messages.any((m) => m.contains('Response:')), isTrue);
    });

    test('logs streaming updates', () async {
      final logger = TestLogger('chat');
      final inner = _ResponseChatClient(ChatResponse());
      final client = LoggingChatClient(inner, logger: logger);

      await client.getStreamingChatResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'hi')],
      ).toList();

      final messages = logger.loggedMessages.map((e) => e.message).toList();
      expect(messages, contains('getStreamingChatResponse invoked.'));
      expect(messages, contains('getStreamingChatResponse completed.'));
      expect(
        messages.any(
            (m) => m.contains('getStreamingChatResponse received update.')),
        isTrue,
      );
    });

    test('logs streaming cancellation and rethrows', () async {
      final logger = TestLogger('chat');
      final exception = OperationCanceledException();
      final inner = _ThrowingStreamingChatClient(exception);
      final client = LoggingChatClient(inner, logger: logger);

      await expectLater(
        client.getStreamingChatResponse(
          messages: [ChatMessage.fromText(ChatRole.user, 'hi')],
        ).toList(),
        throwsA(exception),
      );

      final messages = logger.loggedMessages.map((e) => e.message).toList();
      expect(messages, contains('getStreamingChatResponse invoked.'));
      expect(messages, contains('getStreamingChatResponse canceled.'));
    });

    test('logs streaming errors and rethrows', () async {
      final logger = TestLogger('chat');
      final exception = Exception('stream fail');
      final inner = _ThrowingStreamingChatClient(exception);
      final client = LoggingChatClient(inner, logger: logger);

      await expectLater(
        client.getStreamingChatResponse(
          messages: [ChatMessage.fromText(ChatRole.user, 'hi')],
        ).toList(),
        throwsA(exception),
      );

      final entry = logger.loggedMessages
          .firstWhere((e) => e.message == 'getStreamingChatResponse failed.');
      expect(entry.error, exception);
    });

    test('logs cancellation and rethrows', () async {
      final logger = TestLogger('chat');
      final inner = _ThrowingChatClient(OperationCanceledException());
      final client = LoggingChatClient(inner, logger: logger);

      await expectLater(
        client.getChatResponse(
          messages: [ChatMessage.fromText(ChatRole.user, 'hi')],
        ),
        throwsA(isA<OperationCanceledException>()),
      );

      final messages = logger.loggedMessages.map((e) => e.message).toList();
      expect(messages, contains('getChatResponse invoked.'));
      expect(messages, contains('getChatResponse canceled.'));
    });

    test('logs errors and rethrows', () async {
      final logger = TestLogger('chat');
      final exception = Exception('boom');
      final inner = _ThrowingChatClient(exception);
      final client = LoggingChatClient(inner, logger: logger);

      await expectLater(
        client.getChatResponse(
          messages: [ChatMessage.fromText(ChatRole.user, 'hi')],
        ),
        throwsA(exception),
      );

      final entry = logger.loggedMessages
          .firstWhere((e) => e.message == 'getChatResponse failed.');
      expect(entry.error, exception);
    });
  });

  group('LoggingEmbeddingGenerator', () {
    test('logs invocation and completion', () async {
      final logger = TestLogger('embeddings');
      final inner = _EmbeddingGenerator();
      final generator = LoggingEmbeddingGenerator(inner, logger: logger);

      await generator.generateEmbeddings(
        values: ['a', 'b'],
        options: EmbeddingGenerationOptions(modelId: 'model'),
      );

      final messages = logger.loggedMessages.map((e) => e.message).toList();
      expect(messages, contains('generateEmbeddings invoked.'));
      expect(messages, contains('generateEmbeddings completed.'));
      expect(messages.any((m) => m.contains('Values count: 2.')), isTrue);
    });

    test('logs errors and rethrows', () async {
      final logger = TestLogger('embeddings');
      final exception = Exception('fail');
      final inner = _ThrowingEmbeddingGenerator(exception);
      final generator = LoggingEmbeddingGenerator(inner, logger: logger);

      await expectLater(
        generator.generateEmbeddings(values: ['a']),
        throwsA(exception),
      );

      final entry = logger.loggedMessages
          .firstWhere((e) => e.message == 'generateEmbeddings failed.');
      expect(entry.error, exception);
    });

    test('logs cancellation and rethrows', () async {
      final logger = TestLogger('embeddings');
      final exception = OperationCanceledException();
      final inner = _ThrowingEmbeddingGenerator(exception);
      final generator = LoggingEmbeddingGenerator(inner, logger: logger);

      await expectLater(
        generator.generateEmbeddings(values: ['a']),
        throwsA(exception),
      );

      final messages = logger.loggedMessages.map((e) => e.message).toList();
      expect(messages, contains('generateEmbeddings invoked.'));
      expect(messages, contains('generateEmbeddings canceled.'));
    });
  });

  group('LoggingImageGenerator', () {
    test('logs invocation and completion', () async {
      final logger = TestLogger('images');
      final inner = _ImageGenerator();
      final generator = LoggingImageGenerator(inner, logger: logger);

      await generator.generate(
        request: ImageGenerationRequest(prompt: 'draw'),
        options: ImageGenerationOptions(modelId: 'model'),
      );

      final messages = logger.loggedMessages.map((e) => e.message).toList();
      expect(messages, contains('generate invoked.'));
      expect(messages, contains('generate completed.'));
      expect(messages.any((m) => m.contains('Prompt: draw.')), isTrue);
    });

    test('logs errors and rethrows', () async {
      final logger = TestLogger('images');
      final exception = Exception('image fail');
      final inner = _ThrowingImageGenerator(exception);
      final generator = LoggingImageGenerator(inner, logger: logger);

      await expectLater(
        generator.generate(request: ImageGenerationRequest(prompt: 'x')),
        throwsA(exception),
      );

      final entry = logger.loggedMessages
          .firstWhere((e) => e.message == 'generate failed.');
      expect(entry.error, exception);
    });

    test('logs cancellation and rethrows', () async {
      final logger = TestLogger('images');
      final exception = OperationCanceledException();
      final inner = _ThrowingImageGenerator(exception);
      final generator = LoggingImageGenerator(inner, logger: logger);

      await expectLater(
        generator.generate(request: ImageGenerationRequest(prompt: 'x')),
        throwsA(exception),
      );

      final messages = logger.loggedMessages.map((e) => e.message).toList();
      expect(messages, contains('generate invoked.'));
      expect(messages, contains('generate canceled.'));
    });
  });

  group('LoggingSpeechToTextClient', () {
    test('logs invocation and completion', () async {
      final logger = TestLogger('speech');
      final inner = _SpeechToTextClient();
      final client = LoggingSpeechToTextClient(inner, logger: logger);

      await client.getText(
        stream: const Stream<List<int>>.empty(),
        options: SpeechToTextOptions(modelId: 'model'),
      );

      final messages = logger.loggedMessages.map((e) => e.message).toList();
      expect(messages, contains('getText invoked.'));
      expect(messages, contains('getText completed.'));
      expect(messages.any((m) => m.contains('Response:')), isTrue);
    });

    test('logs streaming updates', () async {
      final logger = TestLogger('speech');
      final inner = _SpeechToTextClient();
      final client = LoggingSpeechToTextClient(inner, logger: logger);

      await client
          .getStreamingText(stream: const Stream<List<int>>.empty())
          .toList();

      final messages = logger.loggedMessages.map((e) => e.message).toList();
      expect(messages, contains('getStreamingText invoked.'));
      expect(messages, contains('getStreamingText completed.'));
      expect(
        messages.any((m) => m.contains('getStreamingText received update.')),
        isTrue,
      );
    });

    test('logs errors and rethrows', () async {
      final logger = TestLogger('speech');
      final exception = Exception('speech fail');
      final inner = _ThrowingSpeechToTextClient(exception);
      final client = LoggingSpeechToTextClient(inner, logger: logger);

      await expectLater(
        client.getText(stream: const Stream<List<int>>.empty()),
        throwsA(exception),
      );

      final entry = logger.loggedMessages
          .firstWhere((e) => e.message == 'getText failed.');
      expect(entry.error, exception);
    });

    test('logs streaming cancellation and rethrows', () async {
      final logger = TestLogger('speech');
      final exception = OperationCanceledException();
      final inner = _ThrowingSpeechToTextClient(exception);
      final client = LoggingSpeechToTextClient(inner, logger: logger);

      await expectLater(
        client
            .getStreamingText(stream: const Stream<List<int>>.empty())
            .toList(),
        throwsA(exception),
      );

      final messages = logger.loggedMessages.map((e) => e.message).toList();
      expect(messages, contains('getStreamingText invoked.'));
      expect(messages, contains('getStreamingText canceled.'));
    });

    test('logs streaming errors and rethrows', () async {
      final logger = TestLogger('speech');
      final exception = Exception('stream fail');
      final inner = _ThrowingSpeechToTextClient(exception);
      final client = LoggingSpeechToTextClient(inner, logger: logger);

      await expectLater(
        client
            .getStreamingText(stream: const Stream<List<int>>.empty())
            .toList(),
        throwsA(exception),
      );

      final entry = logger.loggedMessages
          .firstWhere((e) => e.message == 'getStreamingText failed.');
      expect(entry.error, exception);
    });
  });
}

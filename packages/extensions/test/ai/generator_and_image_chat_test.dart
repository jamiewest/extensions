import 'dart:async';

import 'package:extensions/ai.dart';
import 'package:extensions/dependency_injection.dart' show ServiceProvider;
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

class _RecordingImageGenerator implements ImageGenerator {
  ImageGenerationRequest? lastRequest;
  ImageGenerationOptions? lastOptions;
  bool disposed = false;

  @override
  Future<ImageGenerationResponse> generate({
    required ImageGenerationRequest request,
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    lastRequest = request;
    lastOptions = options;
    return ImageGenerationResponse(contents: [TextContent('image')]);
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {
    disposed = true;
  }
}

class _RecordingEmbeddingGenerator implements EmbeddingGenerator {
  Iterable<String>? lastValues;
  EmbeddingGenerationOptions? lastOptions;
  bool disposed = false;

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    lastValues = values;
    lastOptions = options;
    return GeneratedEmbeddings([
      Embedding(vector: [0.1, 0.2])
    ]);
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {
    disposed = true;
  }
}

class _EmbeddingWrapper extends DelegatingEmbeddingGenerator {
  _EmbeddingWrapper(super.innerGenerator, this.label, this.events);

  final String label;
  final List<String> events;

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) {
    events.add(label);
    return super.generateEmbeddings(
      values: values,
      options: options,
      cancellationToken: cancellationToken,
    );
  }
}

class _ImageWrapper extends DelegatingImageGenerator {
  _ImageWrapper(super.innerGenerator, this.label, this.events);

  final String label;
  final List<String> events;

  @override
  Future<ImageGenerationResponse> generate({
    required ImageGenerationRequest request,
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) {
    events.add(label);
    return super.generate(
      request: request,
      options: options,
      cancellationToken: cancellationToken,
    );
  }
}

class _TestServiceProvider implements ServiceProvider {
  @override
  Object? getServiceFromType(Type type) => null;
}

class _SingleResponseChatClient implements ChatClient {
  _SingleResponseChatClient(this.response);

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
  }) =>
      const Stream<ChatResponseUpdate>.empty();

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

void main() {
  group('ImageGeneratingChatClient', () {
    test('invokes image generator and appends result message', () async {
      final imageCall = ImageGenerationToolCallContent(imageId: 'img-1');
      final innerResponse = ChatResponse.fromMessage(
        ChatMessage(
          role: ChatRole.assistant,
          contents: [imageCall],
        ),
      );
      final inner = _SingleResponseChatClient(innerResponse);
      final generator = _RecordingImageGenerator();
      final client = ImageGeneratingChatClient(
        inner,
        imageGenerator: generator,
      );

      final response = await client.getChatResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'start')],
      );

      expect(generator.lastRequest?.prompt, 'img-1');
      expect(response.messages, hasLength(2));
      expect(response.messages.last.role, ChatRole.assistant);
      expect(response.messages.last.contents.single, isA<TextContent>());
      expect(
        (response.messages.last.contents.single as TextContent).text,
        'image',
      );
    });

    test('returns response unchanged when no tool calls', () async {
      final innerResponse = ChatResponse.fromMessage(
        ChatMessage.fromText(ChatRole.assistant, 'ok'),
      );
      final inner = _SingleResponseChatClient(innerResponse);
      final generator = _RecordingImageGenerator();
      final client = ImageGeneratingChatClient(
        inner,
        imageGenerator: generator,
      );

      final response = await client.getChatResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'start')],
      );

      expect(identical(response, innerResponse), isTrue);
      expect(generator.lastRequest, isNull);
    });
  });

  group('EmbeddingGeneratorBuilder', () {
    test('applies middleware in reverse order', () async {
      final events = <String>[];
      final inner = _RecordingEmbeddingGenerator();
      final builder = EmbeddingGeneratorBuilder(inner)
        ..use((gen) => _EmbeddingWrapper(gen, 'first', events))
        ..use((gen) => _EmbeddingWrapper(gen, 'second', events));

      final generator = builder.build();
      await generator.generateEmbeddings(values: ['a']);

      expect(events, ['first', 'second']);
    });

    test('fromFactory receives provided services', () {
      ServiceProvider? captured;
      final provider = _TestServiceProvider();
      final builder = EmbeddingGeneratorBuilder.fromFactory((services) {
        captured = services;
        return _RecordingEmbeddingGenerator();
      });

      builder.build(provider);

      expect(identical(captured, provider), isTrue);
    });
  });

  group('ConfigureOptionsEmbeddingGenerator', () {
    test('applies configuration to options', () async {
      final inner = _RecordingEmbeddingGenerator();
      final generator = ConfigureOptionsEmbeddingGenerator(
        inner,
        configure: (options) {
          options.modelId = 'configured';
          return options;
        },
      );

      await generator.generateEmbeddings(values: ['a']);

      expect(inner.lastOptions?.modelId, 'configured');
    });
  });

  group('ImageGeneratorBuilder', () {
    test('applies middleware in reverse order', () async {
      final events = <String>[];
      final inner = _RecordingImageGenerator();
      final builder = ImageGeneratorBuilder(inner)
        ..use((gen) => _ImageWrapper(gen, 'first', events))
        ..use((gen) => _ImageWrapper(gen, 'second', events));

      final generator = builder.build();
      await generator.generate(request: ImageGenerationRequest(prompt: 'p'));

      expect(events, ['first', 'second']);
    });

    test('fromFactory receives provided services', () {
      ServiceProvider? captured;
      final provider = _TestServiceProvider();
      final builder = ImageGeneratorBuilder.fromFactory((services) {
        captured = services;
        return _RecordingImageGenerator();
      });

      builder.build(provider);

      expect(identical(captured, provider), isTrue);
    });
  });

  group('ConfigureOptionsImageGenerator', () {
    test('applies configuration to options', () async {
      final inner = _RecordingImageGenerator();
      final generator = ConfigureOptionsImageGenerator(
        inner,
        configure: (options) {
          options.modelId = 'configured';
          return options;
        },
      );

      await generator.generate(request: ImageGenerationRequest(prompt: 'p'));

      expect(inner.lastOptions?.modelId, 'configured');
    });
  });
}

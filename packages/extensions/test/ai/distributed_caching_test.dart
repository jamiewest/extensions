import 'dart:convert';
import 'dart:typed_data';

import 'package:extensions/ai.dart';
import 'package:extensions/caching.dart';
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

class _CountingChatClient implements ChatClient {
  int calls = 0;

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    calls++;
    return ChatResponse.fromMessage(
      ChatMessage.fromText(ChatRole.assistant, 'reply-$calls'),
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

class _CountingEmbeddingGenerator implements EmbeddingGenerator {
  int calls = 0;
  final List<List<String>> requestedValues = [];

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    calls++;
    final list = values.toList();
    requestedValues.add(list);
    return GeneratedEmbeddings(
      list
          .map((value) => Embedding(vector: [value.length.toDouble()]))
          .toList(),
    );
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

Uint8List _serializeResponse(ChatResponse response) =>
    Uint8List.fromList(utf8.encode(response.text));

ChatResponse _deserializeResponse(Uint8List data) => ChatResponse.fromMessage(
      ChatMessage.fromText(ChatRole.assistant, utf8.decode(data)),
    );

void main() {
  group('DistributedCachingChatClient', () {
    test('caches responses and serves repeats from the cache', () async {
      final inner = _CountingChatClient();
      final cache = MemoryDistributedCache();
      final client = DistributedCachingChatClient(
        inner,
        storage: cache,
        serializeResponse: _serializeResponse,
        deserializeResponse: _deserializeResponse,
      );

      final messages = [ChatMessage.fromText(ChatRole.user, 'hello')];
      final first = await client.getResponse(messages: messages);
      final second = await client.getResponse(messages: messages);

      expect(inner.calls, equals(1));
      expect(first.text, equals('reply-1'));
      expect(second.text, equals('reply-1'));
    });

    test('different messages miss the cache', () async {
      final inner = _CountingChatClient();
      final client = DistributedCachingChatClient(
        inner,
        storage: MemoryDistributedCache(),
        serializeResponse: _serializeResponse,
        deserializeResponse: _deserializeResponse,
      );

      await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'one')],
      );
      await client.getResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'two')],
      );

      expect(inner.calls, equals(2));
    });

    test('useDistributedCache wires the client into a pipeline', () async {
      final inner = _CountingChatClient();
      final client = inner
          .asBuilder()
          .useDistributedCache(
            storage: MemoryDistributedCache(),
            serializeResponse: _serializeResponse,
            deserializeResponse: _deserializeResponse,
          )
          .build();

      final messages = [ChatMessage.fromText(ChatRole.user, 'hi')];
      await client.getResponse(messages: messages);
      await client.getResponse(messages: messages);

      expect(inner.calls, equals(1));
    });
  });

  group('DistributedCachingEmbeddingGenerator', () {
    test('caches embeddings per value', () async {
      final inner = _CountingEmbeddingGenerator();
      final generator = DistributedCachingEmbeddingGenerator(
        inner,
        storage: MemoryDistributedCache(),
      );

      final first = await generator.generateEmbeddings(values: ['aa', 'b']);
      expect(inner.calls, equals(1));
      expect(first.length, equals(2));
      expect(first[0].vector, equals([2.0]));
      expect(first[1].vector, equals([1.0]));

      final second = await generator.generateEmbeddings(values: ['aa', 'b']);
      expect(inner.calls, equals(1));
      expect(second[0].vector, equals([2.0]));
      expect(second[1].vector, equals([1.0]));
    });

    test('only uncached values are forwarded, order is preserved', () async {
      final inner = _CountingEmbeddingGenerator();
      final generator = DistributedCachingEmbeddingGenerator(
        inner,
        storage: MemoryDistributedCache(),
      );

      await generator.generateEmbeddings(values: ['aa']);
      final result = await generator.generateEmbeddings(values: ['aa', 'ccc']);

      expect(inner.calls, equals(2));
      expect(inner.requestedValues.last, equals(['ccc']));
      expect(result.length, equals(2));
      expect(result[0].vector, equals([2.0]));
      expect(result[1].vector, equals([3.0]));
    });

    test('options participate in the cache key', () async {
      final inner = _CountingEmbeddingGenerator();
      final generator = DistributedCachingEmbeddingGenerator(
        inner,
        storage: MemoryDistributedCache(),
      );

      await generator.generateEmbeddings(values: ['x']);
      await generator.generateEmbeddings(
        values: ['x'],
        options: EmbeddingGenerationOptions(modelId: 'other'),
      );

      expect(inner.calls, equals(2));
    });

    test('the default codec round-trips model id and created time', () async {
      final cache = MemoryDistributedCache();
      final now = DateTime.utc(2026, 7, 4, 12);

      final writer = DistributedCachingEmbeddingGenerator(
        _FixedEmbeddingGenerator(
          Embedding(vector: [1.5, 2.5], modelId: 'm', createdAt: now),
        ),
        storage: cache,
      );
      await writer.generateEmbeddings(values: ['v']);

      final reader = DistributedCachingEmbeddingGenerator(
        _CountingEmbeddingGenerator(),
        storage: cache,
      );
      final result = await reader.generateEmbeddings(values: ['v']);

      expect(result[0].vector, equals([1.5, 2.5]));
      expect(result[0].modelId, equals('m'));
      expect(result[0].createdAt, equals(now));
    });
  });
}

class _FixedEmbeddingGenerator implements EmbeddingGenerator {
  _FixedEmbeddingGenerator(this.embedding);

  final Embedding embedding;

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      GeneratedEmbeddings(values.map((_) => embedding).toList());

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

import 'dart:convert';

import 'package:extensions/ai.dart';
import 'package:test/test.dart';

import 'helpers/verbatim_http_client.dart';

void main() {
  String embeddingJson({
    String model = 'text-embedding-3-small',
    List<List<double>>? vectors,
    int promptTokens = 8,
    int totalTokens = 8,
  }) {
    vectors ??= [
      [0.1, 0.2, 0.3],
    ];
    return jsonEncode({
      'object': 'list',
      'model': model,
      'data': vectors
          .asMap()
          .entries
          .map((e) => {'object': 'embedding', 'index': e.key, 'embedding': e.value})
          .toList(),
      'usage': {
        'prompt_tokens': promptTokens,
        'total_tokens': totalTokens,
      },
    });
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  group('validation', () {
    test('throws when defaultModelDimensions is zero', () {
      expect(
        () => OpenAIEmbeddingGenerator(
          'text-embedding-3-small',
          'key',
          defaultModelDimensions: 0,
        ),
        throwsArgumentError,
      );
    });

    test('throws when defaultModelDimensions is negative', () {
      expect(
        () => OpenAIEmbeddingGenerator(
          'text-embedding-3-small',
          'key',
          defaultModelDimensions: -1,
        ),
        throwsArgumentError,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Metadata
  // ---------------------------------------------------------------------------

  group('metadata', () {
    test('provider name is openai', () {
      final gen = OpenAIEmbeddingGenerator('text-embedding-3-small', 'key');
      expect(gen.metadata.providerName, equals('openai'));
    });

    test('default model id is surfaced', () {
      final gen = OpenAIEmbeddingGenerator('text-embedding-3-small', 'key');
      expect(gen.metadata.defaultModelId, equals('text-embedding-3-small'));
    });

    test('default model dimensions surfaced', () {
      final gen = OpenAIEmbeddingGenerator(
        'text-embedding-3-small',
        'key',
        defaultModelDimensions: 512,
      );
      expect(gen.metadata.defaultModelDimensions, equals(512));
    });

    test('provider uri reflects custom endpoint', () {
      final endpoint = Uri.parse('http://localhost:1234/v1');
      final gen = OpenAIEmbeddingGenerator(
        'model',
        'key',
        options: OpenAIClientOptions(endpoint: endpoint),
      );
      expect(gen.metadata.providerUri, equals(endpoint));
    });
  });

  // ---------------------------------------------------------------------------
  // getService
  // ---------------------------------------------------------------------------

  group('getService', () {
    test('returns metadata', () {
      final gen = OpenAIEmbeddingGenerator('text-embedding-3-small', 'key');
      expect(gen.getService<EmbeddingGeneratorMetadata>(), isNotNull);
    });

    test('returns self', () {
      final gen = OpenAIEmbeddingGenerator('text-embedding-3-small', 'key');
      expect(gen.getService<OpenAIEmbeddingGenerator>(), same(gen));
    });

    test('returns null for unknown type', () {
      final gen = OpenAIEmbeddingGenerator('text-embedding-3-small', 'key');
      expect(gen.getService<String>(), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // generateEmbeddings
  // ---------------------------------------------------------------------------

  group('generateEmbeddings', () {
    test('returns embeddings for input values', () async {
      final fakeHttp = VerbatimHttpClient(
        embeddingJson(vectors: [
          [0.1, 0.2, 0.3],
          [0.4, 0.5, 0.6],
        ]),
      );
      final gen = OpenAIEmbeddingGenerator(
        'text-embedding-3-small',
        'key',
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      final result =
          await gen.generateEmbeddings(values: ['hello', 'world']);

      expect(result.length, equals(2));
      expect(result[0].vector, equals([0.1, 0.2, 0.3]));
      expect(result[1].vector, equals([0.4, 0.5, 0.6]));
    });

    test('populates usage details', () async {
      final fakeHttp = VerbatimHttpClient(
        embeddingJson(promptTokens: 8, totalTokens: 8),
      );
      final gen = OpenAIEmbeddingGenerator(
        'text-embedding-3-small',
        'key',
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      final result = await gen.generateEmbeddings(values: ['hello']);

      expect(result.usage?.inputTokenCount, equals(8));
      expect(result.usage?.totalTokenCount, equals(8));
    });

    test('dimensions sent when defaultModelDimensions set', () async {
      final fakeHttp = VerbatimHttpClient(embeddingJson());
      final gen = OpenAIEmbeddingGenerator(
        'text-embedding-3-small',
        'key',
        defaultModelDimensions: 512,
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      await gen.generateEmbeddings(values: ['hello']);

      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      expect(body['dimensions'], equals(512));
    });

    test('dimensions from options override default', () async {
      final fakeHttp = VerbatimHttpClient(embeddingJson());
      final gen = OpenAIEmbeddingGenerator(
        'text-embedding-3-small',
        'key',
        defaultModelDimensions: 512,
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      await gen.generateEmbeddings(
        values: ['hello'],
        options: EmbeddingGenerationOptions(dimensions: 256),
      );

      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      expect(body['dimensions'], equals(256));
    });

    test('throws on 4xx response', () async {
      final fakeHttp = ErrorHttpClient(statusCode: 401);
      final gen = OpenAIEmbeddingGenerator(
        'text-embedding-3-small',
        'bad-key',
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      await expectLater(
        gen.generateEmbeddings(values: ['hello']),
        throwsStateError,
      );
    });
  });
}

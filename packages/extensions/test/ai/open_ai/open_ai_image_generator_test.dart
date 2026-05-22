import 'dart:convert';

import 'package:extensions/ai.dart';
import 'package:test/test.dart';

import 'helpers/verbatim_http_client.dart';

void main() {
  String imageJson({
    String b64 = 'aGVsbG8=',
    String? url,
  }) =>
      jsonEncode({
        'created': 1234567890,
        'data': [
          if (url != null) {'url': url} else {'b64_json': b64},
        ],
      });

  // ---------------------------------------------------------------------------
  // Metadata
  // ---------------------------------------------------------------------------

  group('metadata', () {
    test('provider name is openai', () {
      final gen = OpenAIImageGenerator('gpt-image-1', 'key');
      expect(gen.metadata.providerName, equals('openai'));
    });

    test('default model id is surfaced', () {
      final gen = OpenAIImageGenerator('dall-e-3', 'key');
      expect(gen.metadata.defaultModelId, equals('dall-e-3'));
    });

    test('provider uri reflects custom endpoint', () {
      final endpoint = Uri.parse('http://localhost:1234/v1');
      final gen = OpenAIImageGenerator(
        'dall-e-3',
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
      final gen = OpenAIImageGenerator('dall-e-3', 'key');
      expect(gen.getService<ImageGeneratorMetadata>(), isNotNull);
    });

    test('returns self', () {
      final gen = OpenAIImageGenerator('dall-e-3', 'key');
      expect(gen.getService<OpenAIImageGenerator>(), same(gen));
    });

    test('returns null for unknown type', () {
      final gen = OpenAIImageGenerator('dall-e-3', 'key');
      expect(gen.getService<String>(), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // generate
  // ---------------------------------------------------------------------------

  group('generate', () {
    test('returns DataContent for b64_json response', () async {
      final fakeHttp = VerbatimHttpClient(imageJson(b64: 'aGVsbG8='));
      final gen = OpenAIImageGenerator(
        'dall-e-3',
        'key',
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      final result = await gen.generate(
        request: ImageGenerationRequest(prompt: 'a cat'),
      );

      expect(result.contents, hasLength(1));
      expect(result.contents.first, isA<DataContent>());
    });

    test('returns UriContent for url response', () async {
      final fakeHttp = VerbatimHttpClient(
        imageJson(url: 'https://example.com/img.png'),
      );
      final gen = OpenAIImageGenerator(
        'dall-e-3',
        'key',
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      final result = await gen.generate(
        request: ImageGenerationRequest(prompt: 'a dog'),
      );

      expect(result.contents, hasLength(1));
      expect(result.contents.first, isA<UriContent>());
    });

    test('prompt is sent in request body', () async {
      final fakeHttp = VerbatimHttpClient(imageJson());
      final gen = OpenAIImageGenerator(
        'dall-e-3',
        'key',
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      await gen.generate(
        request: ImageGenerationRequest(prompt: 'a sunset'),
      );

      final body =
          jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
      expect(body['prompt'], equals('a sunset'));
    });

    test('throws on error response', () async {
      final fakeHttp = ErrorHttpClient(statusCode: 500);
      final gen = OpenAIImageGenerator(
        'dall-e-3',
        'key',
        options: OpenAIClientOptions(httpClient: fakeHttp),
      );

      await expectLater(
        gen.generate(request: ImageGenerationRequest(prompt: 'x')),
        throwsStateError,
      );
    });
  });
}

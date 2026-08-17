import 'package:extensions/ai.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:test/test.dart';

final class _FakeEmbeddingGenerator implements EmbeddingGenerator {
  _FakeEmbeddingGenerator({this.embeddingsPerInput = 1});

  final int embeddingsPerInput;
  Iterable<String>? lastValues;

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    lastValues = values;
    final result = GeneratedEmbeddings();
    for (final value in values) {
      for (var i = 0; i < embeddingsPerInput; i++) {
        result.add(Embedding(vector: [value.length.toDouble(), i.toDouble()]));
      }
    }
    return result;
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

void main() {
  group('EmbeddingGeneratorExtensions', () {
    test('generateEmbedding returns the single embedding', () async {
      final generator = _FakeEmbeddingGenerator();

      final embedding = await generator.generateEmbedding('hello');

      expect(embedding.vector, equals([5.0, 0.0]));
      expect(generator.lastValues, equals(['hello']));
    });

    test('generateEmbedding throws on a count mismatch', () async {
      final generator = _FakeEmbeddingGenerator(embeddingsPerInput: 2);

      await expectLater(
        generator.generateEmbedding('hello'),
        throwsA(isA<InvalidOperationException>()),
      );
    });

    test('generateVector returns the raw vector', () async {
      final generator = _FakeEmbeddingGenerator();

      final vector = await generator.generateVector('abc');

      expect(vector, equals([3.0, 0.0]));
    });

    test('generateAndZip pairs inputs with embeddings in order', () async {
      final generator = _FakeEmbeddingGenerator();

      final pairs = await generator.generateAndZip(['a', 'bb', 'ccc']);

      expect(pairs, hasLength(3));
      expect(pairs[0].$1, 'a');
      expect(pairs[0].$2.vector.first, 1.0);
      expect(pairs[2].$1, 'ccc');
      expect(pairs[2].$2.vector.first, 3.0);
    });

    test('generateAndZip returns empty for empty input '
        'without calling the generator', () async {
      final generator = _FakeEmbeddingGenerator();

      final pairs = await generator.generateAndZip(const []);

      expect(pairs, isEmpty);
      expect(generator.lastValues, isNull);
    });

    test('generateAndZip throws on a count mismatch', () async {
      final generator = _FakeEmbeddingGenerator(embeddingsPerInput: 2);

      await expectLater(
        generator.generateAndZip(['a', 'b']),
        throwsA(isA<InvalidOperationException>()),
      );
    });
  });
}

import 'package:extensions/ai.dart';
import 'package:test/test.dart';

void main() {
  group('UsageDetails', () {
    test('add merges nullable counts and additional counts', () {
      final usage = UsageDetails(
        inputTokenCount: 2,
        cachedInputTokenCount: 1,
        additionalCounts: {'cache': 2},
      );
      final other = UsageDetails(
        outputTokenCount: 3,
        totalTokenCount: 5,
        cachedInputTokenCount: 4,
        additionalCounts: {'cache': 1, 'new': 5},
      );

      usage.add(other);

      expect(usage.inputTokenCount, 2);
      expect(usage.outputTokenCount, 3);
      expect(usage.totalTokenCount, 5);
      expect(usage.cachedInputTokenCount, 5);
      expect(usage.additionalCounts, {'cache': 3, 'new': 5});
    });
  });

  group('Embedding', () {
    test('dimensions returns vector length', () {
      final embedding = Embedding(vector: [0.1, 0.2, 0.3]);
      expect(embedding.dimensions, 3);
    });
  });

  group('GeneratedEmbeddings', () {
    test('manages embeddings collection', () {
      final embeddings = GeneratedEmbeddings([
        Embedding(vector: [1.0, 2.0]),
      ]);

      expect(embeddings.length, 1);
      expect(embeddings.isEmpty, isFalse);

      embeddings.add(Embedding(vector: [3.0]));
      embeddings.addAll([Embedding(vector: [4.0, 5.0])]);

      expect(embeddings.length, 3);

      final list = embeddings.toList();
      expect(list, hasLength(3));
      expect(() => list.add(Embedding(vector: [6.0])), throwsUnsupportedError);
    });
  });
}

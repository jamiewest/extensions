import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

void main() {
  group('VectorSearchResult', () {
    test('stores record and score', () {
      const result = VectorSearchResult('hotel-42', score: 0.95);

      expect(result.record, equals('hotel-42'));
      expect(result.score, equals(0.95));
    });

    test('score defaults to null', () {
      const result = VectorSearchResult({'id': '1'});

      expect(result.score, isNull);
    });

    test('works with generic record types', () {
      const mapResult = VectorSearchResult<Map<String, Object?>>(
        {'id': 'abc', 'name': 'Grand Hotel'},
        score: 0.85,
      );

      expect(mapResult.record['id'], equals('abc'));
      expect(mapResult.score, equals(0.85));
    });

    test('is sealed (final class)', () {
      expect(VectorSearchResult<String>('r'), isA<VectorSearchResult<String>>());
    });
  });
}

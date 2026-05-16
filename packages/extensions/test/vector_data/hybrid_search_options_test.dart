import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

void main() {
  group('HybridSearchOptions', () {
    test('has correct defaults', () {
      final options = HybridSearchOptions<String>();

      expect(options.filter, isNull);
      expect(options.vectorPropertyName, isNull);
      expect(options.additionalPropertyName, isNull);
      expect(options.skip, equals(0));
      expect(options.includeVectors, isFalse);
      expect(options.scoreThreshold, isNull);
    });

    test('accepts all parameters', () {
      final filter = VectorStoreFilter.equalTo('category', 'hotel');
      final options = HybridSearchOptions<String>(
        filter: filter,
        vectorPropertyName: 'embedding',
        additionalPropertyName: 'description',
        skip: 5,
        includeVectors: true,
        scoreThreshold: 0.7,
      );

      expect(options.filter, same(filter));
      expect(options.vectorPropertyName, equals('embedding'));
      expect(options.additionalPropertyName, equals('description'));
      expect(options.skip, equals(5));
      expect(options.includeVectors, isTrue);
      expect(options.scoreThreshold, equals(0.7));
    });

    group('skip validation', () {
      test('constructor throws on negative skip', () {
        expect(
          () => HybridSearchOptions<String>(skip: -1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('setter throws on negative skip', () {
        final options = HybridSearchOptions<String>();

        expect(
          () => options.skip = -5,
          throwsA(isA<ArgumentError>()),
        );
      });

      test('setter accepts positive values', () {
        final options = HybridSearchOptions<String>();
        options.skip = 20;

        expect(options.skip, equals(20));
      });
    });
  });
}

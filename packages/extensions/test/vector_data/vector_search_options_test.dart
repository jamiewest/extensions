import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

void main() {
  group('VectorSearchOptions', () {
    test('has correct defaults', () {
      final options = VectorSearchOptions<String>();

      expect(options.filter, isNull);
      expect(options.vectorPropertyName, isNull);
      expect(options.skip, equals(0));
      expect(options.includeVectors, isFalse);
      expect(options.scoreThreshold, isNull);
    });

    test('accepts all parameters', () {
      final filter = VectorStoreFilter.equalTo('category', 'hotel');
      final options = VectorSearchOptions<String>(
        filter: filter,
        vectorPropertyName: 'embedding',
        skip: 10,
        includeVectors: true,
        scoreThreshold: 0.8,
      );

      expect(options.filter, same(filter));
      expect(options.vectorPropertyName, equals('embedding'));
      expect(options.skip, equals(10));
      expect(options.includeVectors, isTrue);
      expect(options.scoreThreshold, equals(0.8));
    });

    group('skip validation', () {
      test('constructor throws on negative skip', () {
        expect(
          () => VectorSearchOptions<String>(skip: -1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('setter throws on negative skip', () {
        final options = VectorSearchOptions<String>();

        expect(
          () => options.skip = -1,
          throwsA(isA<ArgumentError>()),
        );
      });

      test('setter accepts zero', () {
        final options = VectorSearchOptions<String>(skip: 5);
        options.skip = 0;

        expect(options.skip, equals(0));
      });

      test('setter accepts positive values', () {
        final options = VectorSearchOptions<String>();
        options.skip = 100;

        expect(options.skip, equals(100));
      });
    });

    test('fields are mutable', () {
      final options = VectorSearchOptions<String>();
      final filter = VectorStoreFilter.equalTo('a', 1);

      options.filter = filter;
      options.vectorPropertyName = 'vec';
      options.skip = 5;
      options.includeVectors = true;
      options.scoreThreshold = 0.5;

      expect(options.filter, same(filter));
      expect(options.vectorPropertyName, equals('vec'));
      expect(options.skip, equals(5));
      expect(options.includeVectors, isTrue);
      expect(options.scoreThreshold, equals(0.5));
    });
  });
}

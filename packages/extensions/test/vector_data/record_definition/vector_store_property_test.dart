import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

void main() {
  group('VectorStoreKeyProperty', () {
    test('stores property name', () {
      final prop = VectorStoreKeyProperty('hotelId');

      expect(prop.propertyName, equals('hotelId'));
    });

    test('storageName defaults to null', () {
      final prop = VectorStoreKeyProperty('id');

      expect(prop.storageName, isNull);
    });

    test('storageName is mutable', () {
      final prop = VectorStoreKeyProperty('id');
      prop.storageName = 'hotel_id';

      expect(prop.storageName, equals('hotel_id'));
    });

    test('is a VectorStoreProperty', () {
      expect(VectorStoreKeyProperty('id'), isA<VectorStoreProperty>());
    });
  });

  group('VectorStoreDataProperty', () {
    test('stores property name', () {
      final prop = VectorStoreDataProperty('description');

      expect(prop.propertyName, equals('description'));
    });

    test('defaults: isIndexed and isFullTextIndexed are false', () {
      final prop = VectorStoreDataProperty('content');

      expect(prop.isIndexed, isFalse);
      expect(prop.isFullTextIndexed, isFalse);
    });

    test('isIndexed and isFullTextIndexed are mutable', () {
      final prop = VectorStoreDataProperty('content')
        ..isIndexed = true
        ..isFullTextIndexed = true;

      expect(prop.isIndexed, isTrue);
      expect(prop.isFullTextIndexed, isTrue);
    });
  });

  group('VectorStoreVectorProperty', () {
    test('stores property name', () {
      final prop = VectorStoreVectorProperty('embedding');

      expect(prop.propertyName, equals('embedding'));
    });

    test('accepts dimensions', () {
      final prop = VectorStoreVectorProperty('vec', dimensions: 1536);

      expect(prop.dimensions, equals(1536));
    });

    test('dimensions defaults to null', () {
      final prop = VectorStoreVectorProperty('vec');

      expect(prop.dimensions, isNull);
    });

    test('indexKind and distanceFunction default to null', () {
      final prop = VectorStoreVectorProperty('vec');

      expect(prop.indexKind, isNull);
      expect(prop.distanceFunction, isNull);
    });

    test('indexKind and distanceFunction are mutable', () {
      final prop = VectorStoreVectorProperty('vec')
        ..indexKind = IndexKind.hnsw
        ..distanceFunction = DistanceFunction.cosineSimilarity;

      expect(prop.indexKind, equals(IndexKind.hnsw));
      expect(prop.distanceFunction, equals(DistanceFunction.cosineSimilarity));
    });

    test('embeddingType defaults to null and is mutable', () {
      final prop = VectorStoreVectorProperty('vec');
      expect(prop.embeddingType, isNull);

      prop.embeddingType = String;
      expect(prop.embeddingType, equals(String));
    });
  });
}

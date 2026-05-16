import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

void main() {
  group('VectorStoreMetadata', () {
    test('all properties default to null', () {
      const meta = VectorStoreMetadata();

      expect(meta.vectorStoreSystemName, isNull);
      expect(meta.vectorStoreName, isNull);
    });

    test('constructor accepts values', () {
      const meta = VectorStoreMetadata(
        vectorStoreSystemName: 'Qdrant',
        vectorStoreName: 'my-store',
      );

      expect(meta.vectorStoreSystemName, equals('Qdrant'));
      expect(meta.vectorStoreName, equals('my-store'));
    });
  });

  group('VectorStoreCollectionMetadata', () {
    test('all properties default to null', () {
      const meta = VectorStoreCollectionMetadata();

      expect(meta.vectorStoreSystemName, isNull);
      expect(meta.vectorStoreName, isNull);
      expect(meta.collectionName, isNull);
    });

    test('constructor accepts values', () {
      const meta = VectorStoreCollectionMetadata(
        vectorStoreSystemName: 'Redis',
        vectorStoreName: 'prod',
        collectionName: 'hotels',
      );

      expect(meta.vectorStoreSystemName, equals('Redis'));
      expect(meta.vectorStoreName, equals('prod'));
      expect(meta.collectionName, equals('hotels'));
    });
  });
}

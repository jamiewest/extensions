import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

void main() {
  group('VectorStoreCollectionDefinition', () {
    test('defaults to empty properties list', () {
      final def = VectorStoreCollectionDefinition();

      expect(def.properties, isEmpty);
    });

    test('accepts initial properties', () {
      final key = VectorStoreKeyProperty('id');
      final data = VectorStoreDataProperty('name');
      final vec = VectorStoreVectorProperty('embedding', dimensions: 768);

      final def = VectorStoreCollectionDefinition(
        properties: [key, data, vec],
      );

      expect(def.properties, hasLength(3));
    });

    test('keyProperties returns only key properties', () {
      final def = VectorStoreCollectionDefinition(
        properties: [
          VectorStoreKeyProperty('id'),
          VectorStoreDataProperty('name'),
          VectorStoreVectorProperty('vec'),
          VectorStoreKeyProperty('altId'),
        ],
      );

      expect(def.keyProperties, hasLength(2));
      expect(
        def.keyProperties.map((p) => p.propertyName),
        containsAll(['id', 'altId']),
      );
    });

    test('dataProperties returns only data properties', () {
      final def = VectorStoreCollectionDefinition(
        properties: [
          VectorStoreKeyProperty('id'),
          VectorStoreDataProperty('name'),
          VectorStoreDataProperty('description'),
        ],
      );

      expect(def.dataProperties, hasLength(2));
    });

    test('vectorProperties returns only vector properties', () {
      final def = VectorStoreCollectionDefinition(
        properties: [
          VectorStoreKeyProperty('id'),
          VectorStoreVectorProperty('embedding1', dimensions: 512),
          VectorStoreVectorProperty('embedding2', dimensions: 1536),
        ],
      );

      expect(def.vectorProperties, hasLength(2));
    });

    test('properties list is mutable', () {
      final def = VectorStoreCollectionDefinition();
      def.properties.add(VectorStoreKeyProperty('id'));

      expect(def.properties, hasLength(1));
    });

    test('empty definition has empty typed views', () {
      final def = VectorStoreCollectionDefinition();

      expect(def.keyProperties, isEmpty);
      expect(def.dataProperties, isEmpty);
      expect(def.vectorProperties, isEmpty);
    });
  });
}

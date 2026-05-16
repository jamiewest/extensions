import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

void main() {
  group('VectorStoreCollectionOptions', () {
    test('defaults to null definition and no generator', () {
      final opts = VectorStoreCollectionOptions();

      expect(opts.definition, isNull);
      expect(opts.embeddingGenerator, isNull);
    });

    test('constructor accepts definition', () {
      final definition = VectorStoreCollectionDefinition(
        properties: [VectorStoreKeyProperty('id')],
      );
      final opts = VectorStoreCollectionOptions(definition: definition);

      expect(opts.definition, same(definition));
    });

    test('definition is mutable', () {
      final opts = VectorStoreCollectionOptions();
      final def = VectorStoreCollectionDefinition();

      opts.definition = def;

      expect(opts.definition, same(def));
    });
  });
}

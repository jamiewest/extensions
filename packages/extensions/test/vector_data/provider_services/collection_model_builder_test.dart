import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

// Minimal concrete builder that accepts all types.
final class _TestBuilder extends CollectionModelBuilder {
  _TestBuilder([CollectionModelBuildingOptions? options])
      : super(
          options ??
              const CollectionModelBuildingOptions(
                supportsMultipleVectors: true,
                requiresAtLeastOneVector: false,
              ),
        );

  @override
  bool isDataPropertyTypeValid(Type type, {String? supportedTypes}) => true;

  @override
  bool isVectorPropertyTypeValid(Type type, {String? supportedTypes}) =>
      type == Object;
}

void main() {
  group('CollectionModelBuilder', () {
    late _TestBuilder builder;

    setUp(() => builder = _TestBuilder());

    test('buildDynamic returns CollectionModel with key property', () {
      final definition = VectorStoreCollectionDefinition(
        properties: [VectorStoreKeyProperty('id')],
      );

      final model = builder.buildDynamic(definition);

      expect(model.keyProperties, hasLength(1));
      expect(model.keyProperties.first.modelName, equals('id'));
    });

    test('buildDynamic maps data and vector properties', () {
      final definition = VectorStoreCollectionDefinition(
        properties: [
          VectorStoreKeyProperty('id'),
          VectorStoreDataProperty('title')..isFullTextIndexed = true,
          VectorStoreVectorProperty('embedding', dimensions: 1536),
        ],
      );

      final model = builder.buildDynamic(definition);

      expect(model.dataProperties, hasLength(1));
      expect(model.dataProperties.first.isFullTextIndexed, isTrue);
      expect(model.vectorProperties, hasLength(1));
      expect(model.vectorProperties.first.dimensions, equals(1536));
    });

    test('buildDynamic configures dynamic accessors on all properties', () {
      final definition = VectorStoreCollectionDefinition(
        properties: [
          VectorStoreKeyProperty('id'),
          VectorStoreDataProperty('name'),
        ],
      );

      final model = builder.buildDynamic(definition);
      final record = model.createRecord<Map<String, Object?>>();

      model.keyProperties.first.setValueAsObject(record, '42');
      expect(model.keyProperties.first.getValueAsObject(record), equals('42'));

      model.dataProperties.first.setValueAsObject(record, 'Alice');
      expect(
        model.dataProperties.first.getValueAsObject(record),
        equals('Alice'),
      );
    });

    test('buildDynamic applies storageName override', () {
      final definition = VectorStoreCollectionDefinition(
        properties: [
          VectorStoreKeyProperty('id')..storageName = '_id',
          VectorStoreDataProperty('title'),
        ],
      );

      final model = builder.buildDynamic(definition);

      expect(model.keyProperties.first.storageName, equals('_id'));
      expect(model.dataProperties.first.storageName, equals('title'));
    });

    test('buildDynamic uses reservedKeyStorageName when set', () {
      final b = _TestBuilder(
        const CollectionModelBuildingOptions(
          supportsMultipleVectors: true,
          requiresAtLeastOneVector: false,
          reservedKeyStorageName: 'pk',
        ),
      );

      final definition = VectorStoreCollectionDefinition(
        properties: [
          VectorStoreKeyProperty('id')..storageName = 'ignored',
        ],
      );

      final model = b.buildDynamic(definition);

      expect(model.keyProperties.first.storageName, equals('pk'));
    });

    test('validate throws when no key property', () {
      final definition = VectorStoreCollectionDefinition(
        properties: [VectorStoreDataProperty('title')],
      );

      expect(
        () => builder.buildDynamic(definition),
        throwsStateError,
      );
    });

    test('validate throws when multiple key properties', () {
      final definition = VectorStoreCollectionDefinition(
        properties: [
          VectorStoreKeyProperty('id1'),
          VectorStoreKeyProperty('id2'),
        ],
      );

      expect(
        () => builder.buildDynamic(definition),
        throwsStateError,
      );
    });

    test('validate throws when requiresAtLeastOneVector and none present', () {
      final b = _TestBuilder(
        const CollectionModelBuildingOptions(
          supportsMultipleVectors: true,
          requiresAtLeastOneVector: true,
        ),
      );

      final definition = VectorStoreCollectionDefinition(
        properties: [VectorStoreKeyProperty('id')],
      );

      expect(() => b.buildDynamic(definition), throwsStateError);
    });

    test('validate throws when supportsMultipleVectors=false and two given',
        () {
      final b = _TestBuilder(
        const CollectionModelBuildingOptions(
          supportsMultipleVectors: false,
          requiresAtLeastOneVector: false,
        ),
      );

      final definition = VectorStoreCollectionDefinition(
        properties: [
          VectorStoreKeyProperty('id'),
          VectorStoreVectorProperty('v1', dimensions: 3),
          VectorStoreVectorProperty('v2', dimensions: 3),
        ],
      );

      expect(() => b.buildDynamic(definition), throwsStateError);
    });

    test('validate throws when duplicate storage names', () {
      final definition = VectorStoreCollectionDefinition(
        properties: [
          VectorStoreKeyProperty('id')..storageName = 'shared',
          VectorStoreDataProperty('name')..storageName = 'shared',
        ],
      );

      expect(
        () => builder.buildDynamic(definition),
        throwsStateError,
      );
    });

    test('vectorProperty validates positive dimensions', () {
      final definition = VectorStoreCollectionDefinition(
        properties: [
          VectorStoreKeyProperty('id'),
          VectorStoreVectorProperty('embedding'),
        ],
      );

      expect(() => builder.buildDynamic(definition), throwsStateError);
    });

    test('propertyMap contains all properties by model name', () {
      final definition = VectorStoreCollectionDefinition(
        properties: [
          VectorStoreKeyProperty('id'),
          VectorStoreDataProperty('content'),
          VectorStoreVectorProperty('vec', dimensions: 4),
        ],
      );

      final model = builder.buildDynamic(definition);

      expect(model.propertyMap.keys, containsAll(['id', 'content', 'vec']));
    });

    test('getVectorPropertyOrSingle returns named property', () {
      final definition = VectorStoreCollectionDefinition(
        properties: [
          VectorStoreKeyProperty('id'),
          VectorStoreVectorProperty('v1', dimensions: 3),
          VectorStoreVectorProperty('v2', dimensions: 5),
        ],
      );

      final model = builder.buildDynamic(definition);
      final opts = VectorSearchOptions<Map<String, Object?>>(
        vectorPropertyName: 'v2',
      );

      expect(
        model.getVectorPropertyOrSingle(opts).modelName,
        equals('v2'),
      );
    });
  });
}

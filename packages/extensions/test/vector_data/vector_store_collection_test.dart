import 'package:extensions/system.dart' hide equals;
import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

// A minimal concrete implementation used to verify the abstract contract.
class _FakeCollection extends VectorStoreCollection<String, Map<String, Object?>> {
  _FakeCollection(this._name);

  final String _name;

  @override
  String get name => _name;

  @override
  Future<bool> collectionExistsAsync({CancellationToken? cancellationToken}) =>
      Future.value(false);

  @override
  Future<void> ensureCollectionExistsAsync({
    CancellationToken? cancellationToken,
  }) =>
      Future.value();

  @override
  Future<void> ensureCollectionDeletedAsync({
    CancellationToken? cancellationToken,
  }) =>
      Future.value();

  @override
  Future<Map<String, Object?>?> getAsync(
    String key, {
    RecordRetrievalOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      Future.value(null);

  @override
  Stream<Map<String, Object?>> getBatchAsync(
    Iterable<String> keys, {
    RecordRetrievalOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      Stream.empty();

  @override
  Stream<Map<String, Object?>> getFilteredAsync({
    VectorStoreFilter? filter,
    int? top,
    FilteredRecordRetrievalOptions<Map<String, Object?>>? options,
    CancellationToken? cancellationToken,
  }) =>
      Stream.empty();

  @override
  Future<String> upsertAsync(
    Map<String, Object?> record, {
    CancellationToken? cancellationToken,
  }) =>
      Future.value('key1');

  @override
  Stream<String> upsertBatchAsync(
    Iterable<Map<String, Object?>> records, {
    CancellationToken? cancellationToken,
  }) =>
      Stream.empty();

  @override
  Future<void> deleteAsync(
    String key, {
    CancellationToken? cancellationToken,
  }) =>
      Future.value();

  @override
  Future<void> deleteBatchAsync(
    Iterable<String> keys, {
    CancellationToken? cancellationToken,
  }) =>
      Future.value();

  @override
  Stream<VectorSearchResult<Map<String, Object?>>> searchAsync<TInput>(
    TInput value, {
    int top = 3,
    VectorSearchOptions<Map<String, Object?>>? options,
    CancellationToken? cancellationToken,
  }) =>
      Stream.empty();
}

void main() {
  group('VectorStoreCollection', () {
    late _FakeCollection collection;

    setUp(() {
      collection = _FakeCollection('hotels');
    });

    test('name returns the collection name', () {
      expect(collection.name, equals('hotels'));
    });

    test('collectionExistsAsync returns false from stub', () async {
      expect(await collection.collectionExistsAsync(), isFalse);
    });

    test('getAsync returns null from stub', () async {
      expect(await collection.getAsync('missing-key'), isNull);
    });

    test('upsertAsync returns key from stub', () async {
      expect(await collection.upsertAsync({'id': 'key1'}), equals('key1'));
    });

    test('getBatchAsync emits nothing from stub', () async {
      final results = await collection.getBatchAsync(['a', 'b']).toList();

      expect(results, isEmpty);
    });

    test('searchAsync emits nothing from stub', () async {
      final results =
          await collection.searchAsync([0.1, 0.2]).toList();

      expect(results, isEmpty);
    });

    test('getService returns null by default', () {
      expect(collection.getService<String>(), isNull);
    });

    test('dispose completes without error', () {
      expect(() => collection.dispose(), returnsNormally);
    });

    test('implements IVectorSearchable', () {
      expect(collection, isA<IVectorSearchable<Map<String, Object?>>>());
    });
  });
}

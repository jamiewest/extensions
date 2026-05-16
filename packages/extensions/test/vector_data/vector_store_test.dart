import 'package:extensions/system.dart' hide equals;
import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

// A minimal concrete VectorStore to verify the abstract contract.
class _FakeStore extends VectorStore {
  @override
  VectorStoreCollection<TKey, TRecord> getCollection<TKey, TRecord>(
    String name, {
    VectorStoreCollectionDefinition? definition,
  }) {
    throw UnimplementedError();
  }

  @override
  VectorStoreCollection<String, Map<String, Object?>> getDynamicCollection(
    String name,
    VectorStoreCollectionDefinition definition,
  ) {
    throw UnimplementedError();
  }

  @override
  Stream<String> listCollectionNamesAsync({
    CancellationToken? cancellationToken,
  }) =>
      Stream.fromIterable(['hotels', 'restaurants']);

  @override
  Future<bool> collectionExistsAsync(
    String name, {
    CancellationToken? cancellationToken,
  }) =>
      Future.value(name == 'hotels');

  @override
  Future<void> ensureCollectionDeletedAsync(
    String name, {
    CancellationToken? cancellationToken,
  }) =>
      Future.value();
}

void main() {
  group('VectorStore', () {
    late _FakeStore store;

    setUp(() {
      store = _FakeStore();
    });

    test('listCollectionNamesAsync emits collection names', () async {
      final names = await store.listCollectionNamesAsync().toList();

      expect(names, containsAll(['hotels', 'restaurants']));
    });

    test('collectionExistsAsync returns true for known name', () async {
      expect(await store.collectionExistsAsync('hotels'), isTrue);
    });

    test('collectionExistsAsync returns false for unknown name', () async {
      expect(await store.collectionExistsAsync('unknown'), isFalse);
    });

    test('ensureCollectionDeletedAsync completes without error', () async {
      await expectLater(
        store.ensureCollectionDeletedAsync('hotels'),
        completes,
      );
    });

    test('getService returns null by default', () {
      expect(store.getService<String>(), isNull);
    });

    test('dispose completes without error', () {
      expect(() => store.dispose(), returnsNormally);
    });

    test('getCollection throws UnimplementedError from stub', () {
      expect(
        () => store.getCollection<String, String>('hotels'),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}

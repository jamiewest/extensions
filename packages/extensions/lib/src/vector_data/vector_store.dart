import 'package:extensions/annotations.dart';

import '../system/disposable.dart';
import '../system/threading/cancellation_token.dart';
import 'record_definition/vector_store_collection_definition.dart';
import 'vector_store_collection.dart';

/// Represents a vector store that holds collections of records.
///
/// Use [getCollection] to obtain a typed [VectorStoreCollection], or
/// [getDynamicCollection] for schema-less access via
/// `Map<String, Object?>`.
///
/// Unless otherwise documented, implementations can be expected to be
/// thread-safe and usable concurrently from multiple callers.
///
/// Example:
/// ```dart
/// final store = MyVectorStore(...);
/// final collection = store.getCollection<String, Hotel>(
///   'hotels',
///   definition: hotelDefinition,
/// );
/// ```
@Source(
  name: 'VectorStore.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/',
)
abstract class VectorStore implements Disposable {
  /// Gets a strongly-typed collection of records.
  ///
  /// [name] is the collection name in the store. [definition] provides the
  /// explicit schema; when null the store may derive the schema from
  /// annotations on [TRecord] or from conventions.
  VectorStoreCollection<TKey, TRecord> getCollection<TKey, TRecord>(
    String name, {
    VectorStoreCollectionDefinition? definition,
  });

  /// Gets a dynamic collection that uses `Map<String, Object?>` as the record
  /// type.
  ///
  /// [definition] is required because there is no record type to derive the
  /// schema from.
  VectorStoreCollection<String, Map<String, Object?>> getDynamicCollection(
    String name,
    VectorStoreCollectionDefinition definition,
  );

  /// Returns the names of all collections in the store.
  Stream<String> listCollectionNamesAsync({
    CancellationToken? cancellationToken,
  });

  /// Returns true if a collection named [name] exists in the store.
  Future<bool> collectionExistsAsync(
    String name, {
    CancellationToken? cancellationToken,
  });

  /// Deletes the collection named [name] if it exists.
  Future<void> ensureCollectionDeletedAsync(
    String name, {
    CancellationToken? cancellationToken,
  });

  /// Gets a service of the specified type provided by the underlying store.
  ///
  /// Returns null if the service is unavailable.
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

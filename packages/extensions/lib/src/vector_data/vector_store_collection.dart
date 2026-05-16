import 'package:extensions/annotations.dart';

import '../system/disposable.dart';
import '../system/threading/cancellation_token.dart';
import 'filtered_record_retrieval_options.dart';
import 'i_vector_searchable.dart';
import 'record_retrieval_options.dart';
import 'vector_search_options.dart';
import 'vector_search_result.dart';
import 'vector_store_filter.dart';

/// Represents a collection of records in a vector store.
///
/// Provides CRUD and similarity-search operations for a specific record type.
/// Use [VectorStore.getCollection] to obtain an instance from a store.
///
/// Unless otherwise documented, implementations can be expected to be
/// thread-safe and usable concurrently from multiple callers.
///
/// Example:
/// ```dart
/// final collection = store.getCollection<String, Hotel>('hotels');
/// await collection.ensureCollectionExistsAsync();
///
/// final results = await collection
///   .searchAsync(embedding, top: 5)
///   .toList();
/// ```
@Source(
  name: 'VectorStoreCollection.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/',
)
abstract class VectorStoreCollection<TKey, TRecord>
    implements IVectorSearchable<TRecord>, Disposable {
  /// The name of the collection.
  String get name;

  /// Returns true if the collection exists in the vector store.
  Future<bool> collectionExistsAsync({
    CancellationToken? cancellationToken,
  });

  /// Creates the collection in the vector store if it does not already exist.
  Future<void> ensureCollectionExistsAsync({
    CancellationToken? cancellationToken,
  });

  /// Deletes the collection from the vector store if it exists.
  Future<void> ensureCollectionDeletedAsync({
    CancellationToken? cancellationToken,
  });

  /// Gets the record with the given [key], or null if not found.
  Future<TRecord?> getAsync(
    TKey key, {
    RecordRetrievalOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Gets all records whose keys are in [keys].
  ///
  /// The returned stream emits records in an unspecified order. Records not
  /// found are silently omitted.
  Stream<TRecord> getBatchAsync(
    Iterable<TKey> keys, {
    RecordRetrievalOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Gets records matching an optional [filter].
  ///
  /// [top] limits the number of records returned. When null, the store
  /// may apply its own default limit or return all matching records.
  Stream<TRecord> getFilteredAsync({
    VectorStoreFilter? filter,
    int? top,
    FilteredRecordRetrievalOptions<TRecord>? options,
    CancellationToken? cancellationToken,
  });

  /// Inserts or updates [record] and returns its key.
  Future<TKey> upsertAsync(
    TRecord record, {
    CancellationToken? cancellationToken,
  });

  /// Inserts or updates each record in [records] and yields the resulting keys.
  Stream<TKey> upsertBatchAsync(
    Iterable<TRecord> records, {
    CancellationToken? cancellationToken,
  });

  /// Deletes the record with the given [key].
  ///
  /// Does nothing if no record with that key exists.
  Future<void> deleteAsync(
    TKey key, {
    CancellationToken? cancellationToken,
  });

  /// Deletes all records whose keys are in [keys].
  ///
  /// Does nothing for keys that do not exist.
  Future<void> deleteBatchAsync(
    Iterable<TKey> keys, {
    CancellationToken? cancellationToken,
  });

  @override
  Stream<VectorSearchResult<TRecord>> searchAsync<TInput>(
    TInput value, {
    int top = 3,
    VectorSearchOptions<TRecord>? options,
    CancellationToken? cancellationToken,
  });

  /// Gets a service of the specified type provided by the underlying store.
  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

import 'package:extensions/annotations.dart';

import '../system/threading/cancellation_token.dart';
import 'hybrid_search_options.dart';
import 'vector_search_result.dart';

/// Provides hybrid vector-and-keyword search over a collection of records.
///
/// Hybrid search combines vector similarity with traditional keyword matching
/// to improve recall for queries that have both semantic and lexical
/// characteristics.
@Source(
  name: 'IKeywordHybridSearchable.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/',
)
abstract interface class IKeywordHybridSearchable<TRecord> {
  /// Searches for records that are similar to [value] and match [keywords].
  ///
  /// [value] is the query vector or embedding input. [keywords] is the list of
  /// keyword terms for the lexical portion of the search. [top] is the maximum
  /// number of results to return. [options] controls filtering, skip, and
  /// scoring. [cancellationToken] can be used to cancel the operation.
  Stream<VectorSearchResult<TRecord>> hybridSearchAsync<TInput>(
    TInput value,
    List<String> keywords, {
    int top = 3,
    HybridSearchOptions<TRecord>? options,
    CancellationToken? cancellationToken,
  });

  /// Gets a service of the specified type provided by the underlying store.
  T? getService<T>({Object? key}) => null;
}

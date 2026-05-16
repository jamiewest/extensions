import 'package:extensions/annotations.dart';

import '../system/threading/cancellation_token.dart';
import 'vector_search_options.dart';
import 'vector_search_result.dart';

/// Provides vector similarity search over a collection of records.
///
/// Implemented by [VectorStoreCollection] and by any type that supports
/// similarity search without the full collection management surface.
@Source(
  name: 'IVectorSearchable.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/',
)
abstract interface class IVectorSearchable<TRecord> {
  /// Searches for records that are similar to [value].
  ///
  /// [value] is the query vector or embedding input. The type accepted depends
  /// on the underlying provider. [top] is the maximum number of results to
  /// return. [options] controls filtering, skip, and scoring. [cancellationToken]
  /// can be used to cancel the operation.
  Stream<VectorSearchResult<TRecord>> searchAsync<TInput>(
    TInput value, {
    int top = 3,
    VectorSearchOptions<TRecord>? options,
    CancellationToken? cancellationToken,
  });

  /// Gets a service of the specified type provided by the underlying store.
  ///
  /// Returns null if the service is unavailable. Providers use this hook to
  /// expose implementation-specific capabilities without breaking the
  /// abstract interface.
  T? getService<T>({Object? key}) => null;
}

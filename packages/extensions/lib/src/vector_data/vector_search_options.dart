import 'package:extensions/annotations.dart';

import 'vector_store_filter.dart';

/// Options for a vector similarity search.
///
/// Pass to [IVectorSearchable.searchAsync].
///
/// ```dart
/// final results = await collection.searchAsync(
///   queryEmbedding,
///   top: 5,
///   options: VectorSearchOptions(
///     filter: VectorStoreFilter.equalTo('category', 'hotel'),
///     includeVectors: false,
///     scoreThreshold: 0.75,
///   ),
/// );
/// ```
@Source(
  name: 'VectorSearchOptions.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/',
)
class VectorSearchOptions<TRecord> {
  /// Creates a [VectorSearchOptions].
  VectorSearchOptions({
    this.filter,
    this.vectorPropertyName,
    int skip = 0,
    this.includeVectors = false,
    this.scoreThreshold,
  }) : _skip = skip {
    if (skip < 0) {
      throw ArgumentError.value(skip, 'skip', 'Must be non-negative.');
    }
  }

  /// The filter to apply before performing the vector search.
  VectorStoreFilter? filter;

  /// The name of the vector property to search on.
  ///
  /// When null, the store uses its default or single vector property.
  /// Replaces the C# `Expression<Func<TRecord, object?>>` property selector.
  String? vectorPropertyName;

  int _skip;

  /// The number of results to skip before returning matches.
  ///
  /// Must be non-negative. Defaults to `0`.
  int get skip => _skip;
  set skip(int value) {
    if (value < 0) {
      throw ArgumentError.value(value, 'skip', 'Must be non-negative.');
    }
    _skip = value;
  }

  /// Whether to include vector fields in the returned records.
  bool includeVectors;

  /// The minimum similarity score for returned results.
  ///
  /// Results with a score below this value are excluded.
  double? scoreThreshold;
}

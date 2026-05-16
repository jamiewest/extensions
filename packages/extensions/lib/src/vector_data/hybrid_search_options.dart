import 'package:extensions/annotations.dart';

import 'vector_store_filter.dart';

/// Options for a hybrid vector-and-keyword search.
///
/// Pass to [IKeywordHybridSearchable.hybridSearchAsync].
@Source(
  name: 'HybridSearchOptions.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/',
)
class HybridSearchOptions<TRecord> {
  /// Creates a [HybridSearchOptions].
  HybridSearchOptions({
    this.filter,
    this.vectorPropertyName,
    this.additionalPropertyName,
    int skip = 0,
    this.includeVectors = false,
    this.scoreThreshold,
  }) : _skip = skip {
    if (skip < 0) {
      throw ArgumentError.value(skip, 'skip', 'Must be non-negative.');
    }
  }

  /// The filter to apply before performing the hybrid search.
  VectorStoreFilter? filter;

  /// The name of the vector property to search on.
  ///
  /// When null, the store uses its default or single vector property.
  String? vectorPropertyName;

  /// The name of the additional (keyword/text) property to search on.
  ///
  /// When null, the store uses its default or single full-text-indexed
  /// property.
  String? additionalPropertyName;

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
  double? scoreThreshold;
}

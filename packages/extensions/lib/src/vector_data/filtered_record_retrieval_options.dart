import 'package:extensions/annotations.dart';

import 'vector_store_filter.dart';

/// A clause that defines a single ordering direction for a field.
///
/// Use [OrderByClause.ascending] or [OrderByClause.descending] to construct
/// instances, then pass a list to
/// [FilteredRecordRetrievalOptions.orderBy].
///
/// ```dart
/// final options = FilteredRecordRetrievalOptions<Hotel>()
///   ..orderBy = [
///     OrderByClause.ascending('rating'),
///     OrderByClause.descending('name'),
///   ];
/// ```
final class OrderByClause {
  /// Creates an ascending [OrderByClause] for [fieldName].
  const OrderByClause.ascending(this.fieldName) : descending = false;

  /// Creates a descending [OrderByClause] for [fieldName].
  const OrderByClause.descending(this.fieldName) : descending = true;

  /// The name of the field to sort by.
  final String fieldName;

  /// Whether the sort direction is descending.
  ///
  /// `false` means ascending, `true` means descending.
  final bool descending;
}

/// Options for retrieving records from a vector store collection with optional
/// filtering and ordering.
///
/// Pass to [VectorStoreCollection.getFilteredAsync].
@Source(
  name: 'FilteredRecordRetrievalOptions.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/',
)
class FilteredRecordRetrievalOptions<TRecord> {
  /// Creates a [FilteredRecordRetrievalOptions].
  FilteredRecordRetrievalOptions({
    this.skip = 0,
    this.includeVectors = false,
    this.scoreThreshold,
    this.orderBy,
  });

  /// The number of results to skip before returning records.
  ///
  /// Must be non-negative.
  int skip;

  /// Whether to include vector fields in the retrieved records.
  bool includeVectors;

  /// The minimum score threshold for returned records.
  ///
  /// Records with a score below this value are excluded. The meaning of
  /// "score" depends on the [DistanceFunction] used by the vector property.
  double? scoreThreshold;

  /// The ordered list of sort clauses applied to the results.
  ///
  /// When null, the store determines the default ordering.
  List<OrderByClause>? orderBy;

  /// The filter to apply to the records.
  ///
  /// When null, all records are considered.
  VectorStoreFilter? filter;
}

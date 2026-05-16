import 'package:extensions/annotations.dart';

import 'filter_clause.dart';

/// A filter clause that matches records where a collection field contains a
/// specific string value.
///
/// Deprecated — use [VectorStoreFilter.anyTagEqualTo] instead.
// ignore: deprecated_member_use_from_same_package
@Deprecated('Use VectorStoreFilter.anyTagEqualTo() instead.')
@Source(
  name: 'AnyTagEqualToFilterClause.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/FilterClauses/',
)
// ignore: deprecated_member_use_from_same_package
final class AnyTagEqualToFilterClause extends FilterClause {
  /// Creates an [AnyTagEqualToFilterClause].
  // ignore: deprecated_member_use_from_same_package
  const AnyTagEqualToFilterClause(this.fieldName, this.value) : super();

  /// The name of the collection field to search.
  final String fieldName;

  /// The value that must appear in the collection.
  final String value;
}

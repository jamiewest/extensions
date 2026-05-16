import 'package:extensions/annotations.dart';

import 'filter_clause.dart';

/// A filter clause that matches records where a field equals a specific value.
///
/// Deprecated — use [VectorStoreFilter.equalTo] instead.
// ignore: deprecated_member_use_from_same_package
@Deprecated('Use VectorStoreFilter.equalTo() instead.')
@Source(
  name: 'EqualToFilterClause.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/FilterClauses/',
)
// ignore: deprecated_member_use_from_same_package
final class EqualToFilterClause extends FilterClause {
  /// Creates an [EqualToFilterClause].
  // ignore: deprecated_member_use_from_same_package
  const EqualToFilterClause(this.fieldName, this.value) : super();

  /// The name of the field to compare.
  final String fieldName;

  /// The value the field must equal.
  final Object? value;
}

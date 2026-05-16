import 'package:extensions/annotations.dart';

/// Base class for filter clauses used when querying a vector store.
///
/// Deprecated — use [VectorStoreFilter] and its sealed subclasses instead.
@Deprecated('Use VectorStoreFilter instead.')
@Source(
  name: 'FilterClause.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/FilterClauses/',
)
abstract class FilterClause {
  /// Creates a [FilterClause].
  const FilterClause();
}

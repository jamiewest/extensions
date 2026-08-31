/// Base class for filter clauses used when querying a vector store.
///
/// Deprecated — use [VectorStoreFilter] and its sealed subclasses instead.
@Deprecated('Use VectorStoreFilter instead.')
abstract class FilterClause {
  /// Creates a [FilterClause].
  const FilterClause();
}

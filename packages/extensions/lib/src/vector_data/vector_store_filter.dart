/// Represents a filter to apply when querying a vector store collection.
///
/// [VectorStoreFilter] replaces the LINQ `Expression<Func<TRecord, bool>>`
/// approach from .NET with an explicit sealed-class tree that vector store
/// providers can pattern-match on to translate into their native query
/// language.
///
/// Use the static factory methods to construct filters:
///
/// ```dart
/// final filter = VectorStoreFilter.and([
///   VectorStoreFilter.equalTo('category', 'hotel'),
///   VectorStoreFilter.anyTagEqualTo('tags', 'pool'),
/// ]);
/// ```
sealed class VectorStoreFilter {
  const VectorStoreFilter();

  /// Creates a filter that matches records where [fieldName] equals [value].
  static EqualToVectorStoreFilter equalTo(String fieldName, Object? value) =>
      EqualToVectorStoreFilter(fieldName, value);

  /// Creates a filter that matches records where at least one element of the
  /// collection field [fieldName] equals [value].
  static AnyTagEqualToVectorStoreFilter anyTagEqualTo(
    String fieldName,
    String value,
  ) =>
      AnyTagEqualToVectorStoreFilter(fieldName, value);

  /// Creates a filter that matches records satisfying all [filters].
  static AndVectorStoreFilter and(List<VectorStoreFilter> filters) =>
      AndVectorStoreFilter(filters);

  /// Creates a filter that matches records satisfying at least one of
  /// [filters].
  static OrVectorStoreFilter or(List<VectorStoreFilter> filters) =>
      OrVectorStoreFilter(filters);
}

/// A filter that matches records where a field equals a specific value.
final class EqualToVectorStoreFilter extends VectorStoreFilter {
  /// Creates an [EqualToVectorStoreFilter].
  const EqualToVectorStoreFilter(this.fieldName, this.value);

  /// The name of the field to compare.
  final String fieldName;

  /// The value the field must equal.
  final Object? value;
}

/// A filter that matches records where a collection field contains a specific
/// string value.
final class AnyTagEqualToVectorStoreFilter extends VectorStoreFilter {
  /// Creates an [AnyTagEqualToVectorStoreFilter].
  const AnyTagEqualToVectorStoreFilter(this.fieldName, this.value);

  /// The name of the collection field to search.
  final String fieldName;

  /// The value that must appear in the collection.
  final String value;
}

/// A filter that requires all [filters] to match.
final class AndVectorStoreFilter extends VectorStoreFilter {
  /// Creates an [AndVectorStoreFilter].
  const AndVectorStoreFilter(this.filters);

  /// The filters that must all match.
  final List<VectorStoreFilter> filters;
}

/// A filter that requires at least one of [filters] to match.
final class OrVectorStoreFilter extends VectorStoreFilter {
  /// Creates an [OrVectorStoreFilter].
  const OrVectorStoreFilter(this.filters);

  /// The filters of which at least one must match.
  final List<VectorStoreFilter> filters;
}

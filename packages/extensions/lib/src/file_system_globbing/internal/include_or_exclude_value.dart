/// Pairs a value with whether it represents an include or an exclude filter.
///
/// This API supports infrastructure and is not intended to be used directly.
class IncludeOrExcludeValue<TValue> {
  /// The wrapped value.
  final TValue value;

  /// Whether the value is an include filter (`true`) or an exclude filter
  /// (`false`).
  final bool isInclude;

  /// Creates a value tagged as include or exclude.
  IncludeOrExcludeValue({required this.value, required this.isInclude});
}

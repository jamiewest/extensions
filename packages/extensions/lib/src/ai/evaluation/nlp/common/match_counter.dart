/// Counts occurrences of items and supports set-intersection with min-count
/// semantics (as required by modified BLEU precision).
class MatchCounter<T> {
  final Map<T, int> _counts = {};

  /// Creates a [MatchCounter] from [items].
  MatchCounter(Iterable<T> items) {
    addAll(items);
  }

  /// Creates an empty [MatchCounter].
  MatchCounter.empty();

  /// Adds one occurrence of [item].
  void add(T item) => _counts[item] = (_counts[item] ?? 0) + 1;

  /// Adds all [items].
  void addAll(Iterable<T> items) {
    for (final item in items) {
      add(item);
    }
  }

  /// Total count across all items.
  int sum() => _counts.values.fold(0, (a, b) => a + b);

  /// All entries.
  Iterable<MapEntry<T, int>> get entries => _counts.entries;

  /// Returns the count for [key], or 0 if absent.
  int operator [](T key) => _counts[key] ?? 0;

  /// Whether [key] is present.
  bool containsKey(T key) => _counts.containsKey(key);

  /// Computes the intersection with [other], taking the minimum count for
  /// each shared key (BLEU clipping semantics).
  MatchCounter<T> intersect(MatchCounter<T> other) {
    final result = MatchCounter<T>.empty();
    final smaller = _counts.length <= other._counts.length ? _counts : other._counts;
    final larger = _counts.length <= other._counts.length ? other._counts : _counts;
    for (final entry in smaller.entries) {
      final otherCount = larger[entry.key];
      if (otherCount != null) {
        result._counts[entry.key] =
            entry.value < otherCount ? entry.value : otherCount;
      }
    }
    return result;
  }
}

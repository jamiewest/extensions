class MatchCounter<T> implements Iterable<MapEntry<T, int>> {
  MatchCounter(Iterable<T> items) {
    _ = Throw.ifNull(items, nameof(items));
    addRange(items);
  }

  final Map<T, int> _counts = [];

  int sum() {
    return _counts.values.sum();
  }

  void add(T item) {
    int currentCount;
    if (_counts.tryGetValue(item)) {
      _counts[item] = currentCount + 1;
    } else {
      _counts[item] = 1;
    }
  }

  void addRange(Iterable<T> items) {
    if (items == null) {
      return;
    }
    for (final item in items) {
      add(item);
    }
  }

  MatchCounter<T> intersect(MatchCounter<T> other) {
    _ = Throw.ifNull(other, nameof(other));
    var intersection = MatchCounter<T>();
    (Dictionary<T, int> smaller, Dictionary<T, int> larger) =
            _counts.count < other._counts.count ? (
              _counts,
              other._counts,
            ) : (other._counts, _counts);
    for (final kvp in smaller) {
      int otherCount;
      if (larger.tryGetValue(kvp.key)) {
        intersection._counts[kvp.key] = Math.min(kvp.value, otherCount);
      }
    }
    return intersection;
  }

  String toDebugString() {
    return string.join(",", _counts.select((v) => '${v.key}: ${v.value}'));
  }

  @override
  Iterable<MapEntry<T, int>> getIterable() {
    return _counts.getIterable();
  }

  Iterable getIterable() {
    return ((IEnumerable)_counts).getIterable();
  }
}

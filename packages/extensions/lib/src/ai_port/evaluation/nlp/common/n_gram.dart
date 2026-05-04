class NGram<T> implements Iterable<T> {
  NGram({ReadOnlySpan<T>? values = null});

  final List<T> values;

  int get length {
    return values.length;
  }

  @override
  bool equals({NGram<T>? other, Object? obj, }) {
    return values.sequenceEqual(other.values);
  }

  @override
  int getHashCode() {
    var hashCode = 0;
    for (final value in values) {
      hashCode = HashCode.combine(hashCode, value.getHashCode());
    }
    return hashCode;
  }

  @override
  Iterable<T> getIterable() {
    return ((IEnumerable<T>)values).getIterable();
  }

  Iterable getIterable() {
    return getIterable();
  }

  String toDebugString() {
    return '[${string.join(",", values.select((v) => v.toString()))}]';
  }
}

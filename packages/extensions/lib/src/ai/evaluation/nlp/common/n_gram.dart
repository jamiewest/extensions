import 'match_counter.dart';

/// An n-gram: a contiguous sequence of [n] tokens.
class NGram<T> {
  /// Creates an [NGram] from [values].
  NGram(List<T> values) : _values = List.unmodifiable(values);

  final List<T> _values;

  /// The number of tokens in this n-gram.
  int get length => _values.length;

  /// Returns the token at [index].
  T operator [](int index) => _values[index];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NGram<T> || other.length != length) return false;
    for (var i = 0; i < length; i++) {
      if (_values[i] != other._values[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    var h = 0;
    for (final v in _values) {
      h = Object.hash(h, v);
    }
    return h;
  }

  @override
  String toString() => '[${_values.join(",")}]';
}

/// Extension methods for creating n-grams from token lists.
extension NGramListExtensions<T> on List<T> {
  /// Creates all n-grams of size [n] from this token list.
  List<NGram<T>> createNGrams(int n) {
    if (n <= 0 || length < n) return [];
    return [
      for (var i = 0; i <= length - n; i++) NGram<T>(sublist(i, i + n)),
    ];
  }

  /// Creates a [MatchCounter] over all n-grams of size [n].
  MatchCounter<NGram<T>> createNGramCounts(int n) =>
      MatchCounter<NGram<T>>(createNGrams(n));

  /// Creates all n-grams of sizes [minN]..[maxN] (inclusive).
  List<NGram<T>> createAllNGrams({int minN = 1, int maxN = 4}) {
    final result = <NGram<T>>[];
    for (var n = minN; n <= maxN; n++) {
      result.addAll(createNGrams(n));
    }
    return result;
  }

  /// Creates a [MatchCounter] over all n-grams of sizes [minN]..[maxN].
  MatchCounter<NGram<T>> createAllNGramCounts({int minN = 1, int maxN = 4}) =>
      MatchCounter<NGram<T>>(createAllNGrams(minN: minN, maxN: maxN));
}

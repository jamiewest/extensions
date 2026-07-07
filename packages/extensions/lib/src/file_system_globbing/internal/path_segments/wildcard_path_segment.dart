import '../../util/string_comparison.dart';
import '../i_path_segment.dart';

/// A pattern segment containing one or more `*` wildcards mixed with literal
/// text, such as `*.txt` or `a*b*c`.
///
/// This API supports infrastructure and is not intended to be used directly.
class WildcardPathSegment implements IPathSegment {
  /// A segment that matches any name. The comparison type is irrelevant
  /// because the segment has no literal content to compare.
  static final WildcardPathSegment matchAll = WildcardPathSegment(
    '',
    <String>[],
    '',
    StringComparison.ordinalIgnoreCase,
  );

  final StringComparison _comparisonType;

  /// The literal text before the first `*`.
  final String beginsWith;

  /// The literal fragments between `*` wildcards, in order.
  final List<String> contains;

  /// The literal text after the last `*`.
  final String endsWith;

  final String _normalizedBeginsWith;
  final List<String> _normalizedContains;
  final String _normalizedEndsWith;

  /// Creates a wildcard segment from its literal fragments.
  ///
  /// Fragments are normalized once here so [match] does not re-normalize
  /// them for every candidate name.
  WildcardPathSegment(
    this.beginsWith,
    this.contains,
    this.endsWith,
    StringComparison comparisonType,
  )   : _comparisonType = comparisonType,
        _normalizedBeginsWith = stringComparisonKey(beginsWith, comparisonType),
        _normalizedContains = [
          for (final fragment in contains)
            stringComparisonKey(fragment, comparisonType),
        ],
        _normalizedEndsWith = stringComparisonKey(endsWith, comparisonType);

  @override
  bool get canProduceStem => true;

  @override
  bool match(String value) {
    if (value.length < beginsWith.length + endsWith.length) {
      return false;
    }

    final normalized = stringComparisonKey(value, _comparisonType);
    if (!normalized.startsWith(_normalizedBeginsWith)) {
      return false;
    }

    if (!normalized.endsWith(_normalizedEndsWith)) {
      return false;
    }

    var beginRemaining = beginsWith.length;
    final endRemaining = value.length - endsWith.length;
    for (final containsValue in _normalizedContains) {
      final indexOf = normalized.indexOf(containsValue, beginRemaining);
      if (indexOf == -1 || indexOf + containsValue.length > endRemaining) {
        return false;
      }

      beginRemaining = indexOf + containsValue.length;
    }

    return true;
  }
}

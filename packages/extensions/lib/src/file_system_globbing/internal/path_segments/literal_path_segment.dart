import '../../util/string_comparison.dart';
import '../i_path_segment.dart';

/// A pattern segment that matches an exact file or directory name.
///
/// This API supports infrastructure and is not intended to be used directly.
class LiteralPathSegment implements IPathSegment {
  final StringComparison _comparisonType;

  /// The literal name to match.
  final String value;

  final String _normalizedValue;

  /// Creates a segment that matches [value] under [comparisonType].
  LiteralPathSegment(this.value, StringComparison comparisonType)
      : _comparisonType = comparisonType,
        _normalizedValue = stringComparisonKey(value, comparisonType);

  @override
  bool get canProduceStem => false;

  @override
  bool match(String value) =>
      _normalizedValue == stringComparisonKey(value, _comparisonType);

  @override
  bool operator ==(Object other) =>
      other is LiteralPathSegment &&
      _comparisonType == other._comparisonType &&
      _normalizedValue == other._normalizedValue;

  @override
  int get hashCode => _normalizedValue.hashCode;
}

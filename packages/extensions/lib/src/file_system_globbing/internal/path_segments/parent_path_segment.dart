import '../i_path_segment.dart';

/// The `..` pattern segment, which refers to the parent directory.
///
/// This API supports infrastructure and is not intended to be used directly.
class ParentPathSegment implements IPathSegment {
  static const String _literalParent = '..';

  @override
  bool get canProduceStem => false;

  @override
  bool match(String value) => value == _literalParent;
}

import '../i_path_segment.dart';

/// The `**` pattern segment, which matches any number of directory levels.
///
/// This API supports infrastructure and is not intended to be used directly.
class RecursiveWildcardSegment implements IPathSegment {
  @override
  bool get canProduceStem => true;

  @override
  bool match(String value) => false;
}

import '../i_path_segment.dart';

/// The `.` pattern segment, which refers to the current directory.
///
/// This API supports infrastructure and is not intended to be used directly.
class CurrentPathSegment implements IPathSegment {
  @override
  bool get canProduceStem => false;

  @override
  bool match(String value) => false;
}

import '../../../system/exceptions/invalid_operation_exception.dart';
import '../../abstractions/directory_info_base.dart';
import '../i_pattern_context.dart';
import '../path_segments/wildcard_path_segment.dart';
import 'pattern_context_ragged.dart';

/// A ragged pattern applied as an include filter.
///
/// This API supports infrastructure and is not intended to be used directly.
class PatternContextRaggedInclude extends PatternContextRagged {
  /// Creates an include context for [pattern].
  PatternContextRaggedInclude(super.pattern);

  @override
  void declare(OnDeclareSegment onDeclare) {
    if (isStackEmpty()) {
      throw InvalidOperationException(
        message: 'Can\'t declare path segment before entering a directory.',
      );
    }

    if (frame.isNotApplicable) {
      return;
    }

    if (isStartingGroup() && frame.segmentIndex < frame.segmentGroup.length) {
      onDeclare(frame.segmentGroup[frame.segmentIndex], false);
    } else {
      onDeclare(WildcardPathSegment.matchAll, false);
    }
  }

  @override
  bool testDirectory(DirectoryInfoBase directory) {
    if (isStackEmpty()) {
      throw InvalidOperationException(
        message: 'Can\'t test directory before entering a directory.',
      );
    }

    if (frame.isNotApplicable) {
      return false;
    }

    if (isStartingGroup() && !testMatchingSegment(directory.name)) {
      // Deterministically not included.
      return false;
    }

    return true;
  }
}

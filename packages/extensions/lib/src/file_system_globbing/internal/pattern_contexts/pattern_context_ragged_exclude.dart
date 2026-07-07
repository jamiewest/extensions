import '../../../system/exceptions/invalid_operation_exception.dart';
import '../../abstractions/directory_info_base.dart';
import 'pattern_context_ragged.dart';

/// A ragged pattern applied as an exclude filter.
///
/// This API supports infrastructure and is not intended to be used directly.
class PatternContextRaggedExclude extends PatternContextRagged {
  /// Creates an exclude context for [pattern].
  PatternContextRaggedExclude(super.pattern);

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

    if (isEndingGroup() && testMatchingGroup(directory)) {
      // The directory is excluded by a file-like pattern.
      return true;
    }

    if (pattern.endsWith.isEmpty &&
        frame.segmentGroupIndex == pattern.contains.length - 1 &&
        testMatchingGroup(directory)) {
      // The directory is excluded by matching up to a final '/**'.
      return true;
    }

    return false;
  }
}

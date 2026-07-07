import '../../../system/exceptions/invalid_operation_exception.dart';
import '../../abstractions/directory_info_base.dart';
import 'pattern_context_linear.dart';

/// A linear pattern applied as an exclude filter.
///
/// This API supports infrastructure and is not intended to be used directly.
class PatternContextLinearExclude extends PatternContextLinear {
  /// Creates an exclude context for [pattern].
  PatternContextLinearExclude(super.pattern);

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

    return isLastSegment() && testMatchingSegment(directory.name);
  }
}

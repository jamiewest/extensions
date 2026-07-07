import '../../../system/exceptions/invalid_operation_exception.dart';
import '../../abstractions/directory_info_base.dart';
import '../i_pattern_context.dart';
import 'pattern_context_linear.dart';

/// A linear pattern applied as an include filter.
///
/// This API supports infrastructure and is not intended to be used directly.
class PatternContextLinearInclude extends PatternContextLinear {
  /// Creates an include context for [pattern].
  PatternContextLinearInclude(super.pattern);

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

    if (frame.segmentIndex < pattern.segments.length) {
      onDeclare(pattern.segments[frame.segmentIndex], isLastSegment());
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

    return !isLastSegment() && testMatchingSegment(directory.name);
  }
}

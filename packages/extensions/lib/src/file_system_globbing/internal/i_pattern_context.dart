import '../abstractions/directory_info_base.dart';
import '../abstractions/file_info_base.dart';
import 'i_path_segment.dart';
import 'pattern_test_result.dart';

/// Callback used by [IPatternContext.declare] to report the pattern segment
/// that applies to the current directory.
typedef OnDeclareSegment = void Function(
  IPathSegment segment,
  bool isLastSegment,
);

/// Tracks the state of a single pattern while a directory tree is walked.
///
/// The `I` prefix intentionally mirrors the upstream C# type
/// `Microsoft.Extensions.FileSystemGlobbing.Internal.IPatternContext`. This
/// API supports infrastructure and is not intended to be used directly.
abstract interface class IPatternContext {
  /// Reports the segment that applies to the current directory via
  /// [onDeclare].
  void declare(OnDeclareSegment onDeclare);

  /// Tests whether the walk should descend into [directory].
  bool testDirectory(DirectoryInfoBase directory);

  /// Tests whether [file] matches the pattern at the current position.
  PatternTestResult testFile(FileInfoBase file);

  /// Pushes [directory] onto the traversal stack.
  void pushDirectory(DirectoryInfoBase directory);

  /// Pops the most recently pushed directory off the traversal stack.
  void popDirectory();
}

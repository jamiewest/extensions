import '../../abstractions/directory_info_base.dart';
import '../../abstractions/file_info_base.dart';
import '../i_pattern_context.dart';
import '../pattern_test_result.dart';

/// Combines multiple pattern contexts into a single include/exclude
/// decision.
///
/// This API supports infrastructure and is not intended to be used directly.
abstract class CompositePatternContext implements IPatternContext {
  /// Evaluates the child contexts for [fileInfo] using [test] and combines
  /// their results.
  PatternTestResult matchPatternContexts<TFileInfoBase>(
    TFileInfoBase fileInfo,
    PatternTestResult Function(IPatternContext context, TFileInfoBase file)
    test,
  );

  @override
  bool testDirectory(DirectoryInfoBase directory) =>
      matchPatternContexts<DirectoryInfoBase>(
        directory,
        (context, dir) => context.testDirectory(dir)
            ? PatternTestResult.success('')
            : PatternTestResult.failed,
      ).isSuccessful;

  @override
  PatternTestResult testFile(FileInfoBase file) =>
      matchPatternContexts<FileInfoBase>(
        file,
        (context, fileInfo) => context.testFile(fileInfo),
      );
}

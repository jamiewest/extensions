import '../../abstractions/directory_info_base.dart';
import '../i_pattern_context.dart';
import '../pattern_test_result.dart';
import 'composite_pattern_context.dart';

/// Applies all include contexts before all exclude contexts, regardless of
/// the order the patterns were added.
///
/// This API supports infrastructure and is not intended to be used directly.
class IncludesFirstCompositePatternContext extends CompositePatternContext {
  final List<IPatternContext> _includePatternContexts;
  final List<IPatternContext> _excludePatternContexts;

  /// Creates a composite over [includePatternContexts] and
  /// [excludePatternContexts].
  IncludesFirstCompositePatternContext(
    List<IPatternContext> includePatternContexts,
    List<IPatternContext> excludePatternContexts,
  ) : _includePatternContexts = includePatternContexts,
      _excludePatternContexts = excludePatternContexts;

  @override
  void declare(OnDeclareSegment onDeclare) {
    for (final include in _includePatternContexts) {
      include.declare(onDeclare);
    }
  }

  @override
  PatternTestResult matchPatternContexts<TFileInfoBase>(
    TFileInfoBase fileInfo,
    PatternTestResult Function(IPatternContext context, TFileInfoBase file)
    test,
  ) {
    var result = PatternTestResult.failed;

    // If the file or directory matches any include pattern, continue.
    for (final context in _includePatternContexts) {
      final localResult = test(context, fileInfo);
      if (localResult.isSuccessful) {
        result = localResult;
        break;
      }
    }

    if (!result.isSuccessful) {
      return PatternTestResult.failed;
    }

    // If the file or directory matches any exclude pattern, it is dropped.
    for (final context in _excludePatternContexts) {
      if (test(context, fileInfo).isSuccessful) {
        return PatternTestResult.failed;
      }
    }

    return result;
  }

  @override
  void popDirectory() {
    for (final context in _excludePatternContexts) {
      context.popDirectory();
    }

    for (final context in _includePatternContexts) {
      context.popDirectory();
    }
  }

  @override
  void pushDirectory(DirectoryInfoBase directory) {
    for (final context in _includePatternContexts) {
      context.pushDirectory(directory);
    }

    for (final context in _excludePatternContexts) {
      context.pushDirectory(directory);
    }
  }
}

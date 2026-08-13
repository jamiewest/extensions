import '../../abstractions/directory_info_base.dart';
import '../i_pattern_context.dart';
import '../include_or_exclude_value.dart';
import '../pattern_test_result.dart';
import 'composite_pattern_context.dart';

/// Applies include and exclude contexts in the order the patterns were
/// added, so a later include can re-admit a file dropped by an earlier
/// exclude.
///
/// This API supports infrastructure and is not intended to be used directly.
class PreserveOrderCompositePatternContext extends CompositePatternContext {
  final List<IncludeOrExcludeValue<IPatternContext>>
  _includeOrExcludePatternContexts;

  /// Creates a composite over [includeOrExcludePatternContexts].
  PreserveOrderCompositePatternContext(
    List<IncludeOrExcludeValue<IPatternContext>>
    includeOrExcludePatternContexts,
  ) : _includeOrExcludePatternContexts = includeOrExcludePatternContexts;

  @override
  void declare(OnDeclareSegment onDeclare) {
    for (final context in _includeOrExcludePatternContexts) {
      if (context.isInclude) {
        context.value.declare(onDeclare);
      }
    }
  }

  @override
  PatternTestResult matchPatternContexts<TFileInfoBase>(
    TFileInfoBase fileInfo,
    PatternTestResult Function(IPatternContext context, TFileInfoBase file)
    test,
  ) {
    var result = PatternTestResult.failed;

    for (final context in _includeOrExcludePatternContexts) {
      // Test excludes only while the file is a match, and includes only
      // while it is not, so each filter can flip the running result.
      if (result.isSuccessful != context.isInclude) {
        final localResult = test(context.value, fileInfo);
        if (localResult.isSuccessful) {
          result = context.isInclude ? localResult : PatternTestResult.failed;
        }
      }
    }

    return result;
  }

  @override
  void popDirectory() {
    for (final context in _includeOrExcludePatternContexts) {
      context.value.popDirectory();
    }
  }

  @override
  void pushDirectory(DirectoryInfoBase directory) {
    for (final context in _includeOrExcludePatternContexts) {
      context.value.pushDirectory(directory);
    }
  }
}

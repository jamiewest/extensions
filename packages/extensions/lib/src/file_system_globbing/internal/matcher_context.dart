import '../abstractions/directory_info_base.dart';
import '../abstractions/file_info_base.dart';
import '../abstractions/file_system_info_base.dart';
import '../file_pattern_match.dart';
import '../pattern_matching_result.dart';
import '../util/string_comparison.dart';
import 'i_path_segment.dart';
import 'i_pattern.dart';
import 'i_pattern_context.dart';
import 'include_or_exclude_value.dart';
import 'path_segments/literal_path_segment.dart';
import 'path_segments/parent_path_segment.dart';
import 'path_segments/wildcard_path_segment.dart';
import 'pattern_contexts/includes_first_composite_pattern_context.dart';
import 'pattern_contexts/preserve_order_composite_pattern_context.dart';

/// Walks a directory tree and collects the files matched by a set of
/// include and exclude patterns.
///
/// This API supports infrastructure and is not intended to be used directly.
class MatcherContext {
  final DirectoryInfoBase _root;
  final IPatternContext _patternContext;
  final List<FilePatternMatch> _files = [];
  final StringComparison _comparison;

  final Set<String> _declaredLiteralFolderSegments = {};
  final Set<LiteralPathSegment> _declaredLiteralFileSegments = {};

  bool _declaredParentPathSegment = false;
  bool _declaredWildcardPathSegment = false;

  /// Creates a context that applies [includePatterns] before
  /// [excludePatterns] while walking [directoryInfo].
  MatcherContext(
    Iterable<IPattern> includePatterns,
    Iterable<IPattern> excludePatterns,
    DirectoryInfoBase directoryInfo,
    StringComparison comparison,
  )   : _root = directoryInfo,
        _comparison = comparison,
        _patternContext = IncludesFirstCompositePatternContext(
          includePatterns
              .map((pattern) => pattern.createPatternContextForInclude())
              .toList(),
          excludePatterns
              .map((pattern) => pattern.createPatternContextForExclude())
              .toList(),
        );

  /// Creates a context that applies [orderedPatterns] in the order they
  /// were added while walking [directoryInfo].
  MatcherContext.preserveOrder(
    List<IncludeOrExcludeValue<IPattern>> orderedPatterns,
    DirectoryInfoBase directoryInfo,
    StringComparison comparison,
  )   : _root = directoryInfo,
        _comparison = comparison,
        _patternContext = PreserveOrderCompositePatternContext(
          orderedPatterns
              .map(
                (item) => IncludeOrExcludeValue<IPatternContext>(
                  value: item.isInclude
                      ? item.value.createPatternContextForInclude()
                      : item.value.createPatternContextForExclude(),
                  isInclude: item.isInclude,
                ),
              )
              .toList(),
        );

  /// Walks the directory tree and returns the matched files.
  PatternMatchingResult execute() {
    _files.clear();

    _match(_root, null);

    return PatternMatchingResult(List.of(_files));
  }

  void _match(DirectoryInfoBase directory, String? parentRelativePath) {
    // Ask every pattern to push the current directory onto its stack.
    _patternContext.pushDirectory(directory);
    _declare();

    final entities = <FileSystemInfoBase?>[];
    if (_declaredWildcardPathSegment ||
        _declaredLiteralFileSegments.isNotEmpty) {
      entities.addAll(directory.enumerateFileSystemInfos());
    } else {
      for (final candidate in directory.enumerateFileSystemInfos()) {
        if (candidate is DirectoryInfoBase &&
            _declaredLiteralFolderSegments
                .contains(stringComparisonKey(candidate.name, _comparison))) {
          entities.add(candidate);
        }
      }
    }

    if (_declaredParentPathSegment) {
      entities.add(directory.getDirectory('..'));
    }

    final subDirectories = <DirectoryInfoBase>[];
    for (final entity in entities) {
      if (entity is FileInfoBase) {
        final result = _patternContext.testFile(entity);
        if (result.isSuccessful) {
          _files.add(
            FilePatternMatch(
              combinePath(parentRelativePath, entity.name),
              result.stem,
            ),
          );
        }
        continue;
      }

      if (entity is DirectoryInfoBase) {
        if (_patternContext.testDirectory(entity)) {
          subDirectories.add(entity);
        }
        continue;
      }
    }

    for (final subDir in subDirectories) {
      final relativePath = combinePath(parentRelativePath, subDir.name);

      _match(subDir, relativePath);
    }

    // Ask every pattern to pop its status stack.
    _patternContext.popDirectory();
  }

  void _declare() {
    _declaredLiteralFileSegments.clear();
    _declaredParentPathSegment = false;
    _declaredWildcardPathSegment = false;

    _patternContext.declare(_declareInclude);
  }

  void _declareInclude(IPathSegment patternSegment, bool isLastSegment) {
    if (patternSegment is LiteralPathSegment) {
      if (isLastSegment) {
        _declaredLiteralFileSegments.add(patternSegment);
      } else {
        _declaredLiteralFolderSegments
            .add(stringComparisonKey(patternSegment.value, _comparison));
      }
    } else if (patternSegment is ParentPathSegment) {
      _declaredParentPathSegment = true;
    } else if (patternSegment is WildcardPathSegment) {
      _declaredWildcardPathSegment = true;
    }
  }

  /// Joins [left] and [right] with `/`, returning [right] when [left] is
  /// null or empty.
  static String combinePath(String? left, String right) {
    if (left == null || left.isEmpty) {
      return right;
    } else {
      return '$left/$right';
    }
  }
}

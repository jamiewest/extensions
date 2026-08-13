import 'abstractions/directory_info_base.dart';
import 'internal/i_pattern.dart';
import 'internal/include_or_exclude_value.dart';
import 'internal/matcher_context.dart';
import 'internal/patterns/pattern_builder.dart';
import 'pattern_matching_result.dart';
import 'util/string_comparison.dart';

/// Searches the file system for files with names that match specified
/// patterns.
///
/// Patterns given to [addInclude] and [addExclude] are relative to the root
/// directory passed to [execute] and can use the following formats:
///
/// - exact names: `"one.txt"`, `"dir/two.txt"`
/// - `*` matches zero or more characters within a file or directory name:
///   `"*.txt"`, `"readme.*"`, `"styles/*.css"`
/// - `**` matches an arbitrary number of directory levels: `"**/*.cs"`,
///   `"dir/**/*"`
/// - `..` at the beginning of a pattern refers to the parent directory
class Matcher {
  final List<IPattern>? _includePatterns;
  final List<IPattern>? _excludePatterns;
  final List<IncludeOrExcludeValue<IPattern>>? _includeOrExcludePatterns;
  final List<String> _includePatternStrings = [];
  final List<String> _excludePatternStrings = [];
  final PatternBuilder _builder;
  final bool _preserveFilterOrder;

  /// The string comparison used when matching patterns against names.
  final StringComparison comparisonType;

  /// Creates a matcher.
  ///
  /// Matching is case-insensitive unless [comparisonType] is
  /// [StringComparison.ordinal]. When [preserveFilterOrder] is `true`,
  /// filters are applied in the order they were added, so a later include
  /// can re-admit a file dropped by an earlier exclude; otherwise all
  /// includes are applied before all excludes.
  Matcher({
    this.comparisonType = StringComparison.ordinalIgnoreCase,
    bool preserveFilterOrder = false,
  }) : _builder = PatternBuilder(comparisonType),
       _preserveFilterOrder = preserveFilterOrder,
       _includeOrExcludePatterns = preserveFilterOrder ? [] : null,
       _includePatterns = preserveFilterOrder ? null : [],
       _excludePatterns = preserveFilterOrder ? null : [];

  /// The include pattern strings added so far.
  List<String> get includePatterns => List.unmodifiable(_includePatternStrings);

  /// The exclude pattern strings added so far.
  List<String> get excludePatterns => List.unmodifiable(_excludePatternStrings);

  /// Adds a pattern for files the matcher should discover.
  ///
  /// Use `/` as the directory separator, `*` for wildcards within a name,
  /// `**` for arbitrary directory depth, and `..` for a parent directory.
  Matcher addInclude(String pattern) {
    _includePatternStrings.add(pattern);
    if (_preserveFilterOrder) {
      _includeOrExcludePatterns!.add(
        IncludeOrExcludeValue<IPattern>(
          value: _builder.build(pattern),
          isInclude: true,
        ),
      );
    } else {
      _includePatterns!.add(_builder.build(pattern));
    }

    return this;
  }

  /// Adds a pattern for files the matcher should exclude from the results.
  ///
  /// Use `/` as the directory separator, `*` for wildcards within a name,
  /// `**` for arbitrary directory depth, and `..` for a parent directory.
  Matcher addExclude(String pattern) {
    _excludePatternStrings.add(pattern);
    if (_preserveFilterOrder) {
      _includeOrExcludePatterns!.add(
        IncludeOrExcludeValue<IPattern>(
          value: _builder.build(pattern),
          isInclude: false,
        ),
      );
    } else {
      _excludePatterns!.add(_builder.build(pattern));
    }

    return this;
  }

  /// Searches [directoryInfo] for all files matching the patterns added to
  /// this matcher.
  ///
  /// Always returns a [PatternMatchingResult], even when no files matched.
  PatternMatchingResult execute(DirectoryInfoBase directoryInfo) =>
      _preserveFilterOrder
      ? MatcherContext.preserveOrder(
          _includeOrExcludePatterns!,
          directoryInfo,
          comparisonType,
        ).execute()
      : MatcherContext(
          _includePatterns!,
          _excludePatterns!,
          directoryInfo,
          comparisonType,
        ).execute();
}

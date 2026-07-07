/// Provides support for matching file system paths using glob patterns
/// with include/exclude semantics.
///
/// A port of Microsoft.Extensions.FileSystemGlobbing, supporting wildcards
/// and directory recursion for flexible file selection.
///
/// ## Basic Glob Matching
///
/// Match files using glob patterns:
///
/// ```dart
/// final matcher = Matcher()
///   ..addInclude('**/*.dart')
///   ..addExclude('**/*_test.dart');
///
/// final result = matcher.execute(DirectoryInfoWrapper(directory));
///
/// for (final file in result.files) {
///   print(file.path);
/// }
/// ```
///
/// ## Pattern Syntax
///
/// Supported glob pattern features:
///
/// - exact names: `one.txt`, `dir/two.txt`
/// - `*` - matches zero or more characters within a file or directory
///   name, e.g. `*.txt`, `readme.*`, `styles/*.css`
/// - `**` - matches an arbitrary number of directory levels, e.g.
///   `**/*.cs`, `dir/**/*`
/// - `..` - at the beginning of a pattern, refers to the parent directory
/// - a trailing `/` treats the pattern as a directory, e.g. `lib/` is
///   equivalent to `lib/**`
///
/// ## In-Memory Matching
///
/// Test glob patterns against file paths without touching the disk:
///
/// ```dart
/// final matcher = Matcher()..addInclude('*.dart');
/// final result = matcher.matchFiles(
///   ['file1.dart', 'file2.txt'],
///   '/root',
/// );
/// ```
library;

// Abstractions
export 'src/file_system_globbing/abstractions/directory_info_base.dart';
export 'src/file_system_globbing/abstractions/directory_info_wrapper.dart';
export 'src/file_system_globbing/abstractions/file_info_base.dart';
export 'src/file_system_globbing/abstractions/file_info_wrapper.dart';
export 'src/file_system_globbing/abstractions/file_system_info_base.dart';
// Core classes
export 'src/file_system_globbing/file_pattern_match.dart';
// In-memory support
export 'src/file_system_globbing/in_memory_directory_info.dart';
export 'src/file_system_globbing/matcher.dart';
export 'src/file_system_globbing/matcher_extensions.dart';
export 'src/file_system_globbing/pattern_matching_result.dart';
export 'src/file_system_globbing/util/string_comparison.dart';

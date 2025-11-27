/// Provides support for matching file system paths using glob patterns
/// with include/exclude semantics.
///
/// This library enables pattern-based file matching inspired by
/// Microsoft.Extensions.FileSystemGlobbing, supporting wildcards and
/// directory recursion for flexible file selection.
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
/// - `*` - matches any characters except directory separator
/// - `**` - matches any characters including directory separators
/// - `?` - matches any single character
/// - `[abc]` - matches any character in the set
/// - `{a,b}` - matches any of the alternatives
///
/// ## In-Memory Matching
///
/// Test glob patterns against in-memory directory structures:
///
/// ```dart
/// final dir = InMemoryDirectoryInfo('/', [
///   InMemoryFileInfo('file1.dart', dir),
///   InMemoryFileInfo('file2.txt', dir),
/// ]);
///
/// final matcher = Matcher()..addInclude('*.dart');
/// final result = matcher.execute(dir);
/// ```
library;

export 'package:glob/glob.dart';

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

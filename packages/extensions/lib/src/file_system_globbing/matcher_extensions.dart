import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import '../file_providers/providers/physical/default_file_system.dart';
import 'abstractions/directory_info_wrapper.dart';
import 'in_memory_directory_info.dart';
import 'matcher.dart';
import 'pattern_matching_result.dart';

/// Extension methods for [Matcher] to simplify common operations.
extension MatcherExtensions on Matcher {
  /// Adds multiple exclude patterns to the matcher.
  ///
  /// Returns the matcher for method chaining.
  Matcher addExcludePatterns(Iterable<Iterable<String>> patterns) {
    for (final patternGroup in patterns) {
      for (final pattern in patternGroup) {
        addExclude(pattern);
      }
    }
    return this;
  }

  /// Adds multiple include patterns to the matcher.
  ///
  /// Returns the matcher for method chaining.
  Matcher addIncludePatterns(Iterable<Iterable<String>> patterns) {
    for (final patternGroup in patterns) {
      for (final pattern in patternGroup) {
        addInclude(pattern);
      }
    }
    return this;
  }

  /// Searches the directory for all files matching patterns and returns
  /// their full paths.
  ///
  /// [directoryPath] - The root directory to search
  /// [fileSystem] - The filesystem to search; defaults to the platform
  /// filesystem so that in-memory filesystems can be searched on web.
  Iterable<String> getResultsInFullPath(
    String directoryPath, [
    FileSystem? fileSystem,
  ]) {
    final fs = fileSystem ?? defaultFileSystem();
    final dir = fs.directory(directoryPath);
    if (!dir.existsSync()) {
      return const [];
    }

    final result = execute(DirectoryInfoWrapper(dir));

    return result.files
        .map((match) => p.normalize(p.join(directoryPath, match.path)));
  }

  /// Matches a single file path without accessing the file system.
  ///
  /// [file] - The file path to match
  /// [root] - Optional root directory (defaults to current directory)
  PatternMatchingResult matchFile(String file, [String? root]) =>
      matchFiles([file], root);

  /// Matches multiple file paths without accessing the file system.
  ///
  /// [files] - The file paths to match
  /// [root] - Optional root directory (defaults to current directory)
  PatternMatchingResult matchFiles(Iterable<String> files, [String? root]) =>
      execute(InMemoryDirectoryInfo.fromPaths(root ?? p.current, files));
}

import 'package:file/local.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import 'abstractions/directory_info_wrapper.dart';
import 'file_pattern_match.dart';
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
  Iterable<String> getResultsInFullPath(String directoryPath) {
    const fs = LocalFileSystem();
    final dir = fs.directory(directoryPath);
    if (!dir.existsSync()) {
      return const [];
    }

    final directoryInfo = DirectoryInfoWrapper(dir);
    final result = execute(directoryInfo);

    return result.files.map((match) => p.join(directoryPath, match.path));
  }

  /// Matches a single file path without accessing the file system.
  ///
  /// [file] - The file path to match
  /// [root] - Optional root directory (defaults to current directory)
  PatternMatchingResult matchFile(String file, [String? root]) {
    final rootPath = root ?? p.current;
    final relativePath = p.relative(file, from: rootPath);

    // Check if the file matches any include patterns
    final includeMatches = _matchesIncludePatterns(relativePath);

    if (!includeMatches) {
      return PatternMatchingResult(const []);
    }

    // Check if the file is excluded
    if (_matchesExcludePatterns(relativePath)) {
      return PatternMatchingResult(const []);
    }

    return PatternMatchingResult([FilePatternMatch(relativePath)]);
  }

  /// Matches multiple file paths without accessing the file system.
  ///
  /// [files] - The file paths to match
  /// [root] - Optional root directory (defaults to current directory)
  PatternMatchingResult matchFiles(Iterable<String> files, [String? root]) {
    final rootPath = root ?? p.current;
    final matches = <FilePatternMatch>[];

    for (final file in files) {
      final relativePath = p.relative(file, from: rootPath);

      // Check if the file matches any include patterns
      if (!_matchesIncludePatterns(relativePath)) {
        continue;
      }

      // Check if the file is excluded
      if (_matchesExcludePatterns(relativePath)) {
        continue;
      }

      matches.add(FilePatternMatch(relativePath));
    }

    return PatternMatchingResult(matches);
  }

  bool _matchesIncludePatterns(String path) {
    if (includePatterns.isEmpty) {
      return true; // No include patterns means include everything
    }

    for (final pattern in includePatterns) {
      if (Glob(pattern).matches(path)) {
        return true;
      }
    }

    return false;
  }

  bool _matchesExcludePatterns(String path) {
    for (final pattern in excludePatterns) {
      if (Glob(pattern).matches(path)) {
        return true;
      }
    }

    return false;
  }
}

import 'dart:io';

import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import 'abstractions/directory_info_base.dart';
import 'file_pattern_match.dart';
import 'pattern_matching_result.dart';

/// Searches the file system for files with names that match specified patterns.
///
/// Supports both include and exclude glob patterns for flexible file matching.
class Matcher {
  final _includePatterns = <String>[];
  final _excludePatterns = <String>[];

  /// Gets the list of include patterns.
  List<String> get includePatterns => List.unmodifiable(_includePatterns);

  /// Gets the list of exclude patterns.
  List<String> get excludePatterns => List.unmodifiable(_excludePatterns);

  /// Adds a glob pattern to include files in the search results.
  ///
  /// Patterns can include:
  /// - Exact paths: `"file.txt"` or `"dir/file.txt"`
  /// - Wildcards: `"*.txt"` matches all .txt files
  /// - Deep matching: `"**/*.cs"` matches .cs files in any subdirectory
  Matcher addInclude(String pattern) {
    _includePatterns.add(pattern);
    return this;
  }

  /// Adds a glob pattern to exclude files from the search results.
  ///
  /// Exclude patterns are applied after include patterns to filter out
  /// unwanted matches.
  Matcher addExclude(String pattern) {
    _excludePatterns.add(pattern);
    return this;
  }

  /// Executes the matcher against the specified directory.
  ///
  /// Returns a [PatternMatchingResult] containing all files that match
  /// the include patterns and don't match any exclude patterns.
  PatternMatchingResult execute(DirectoryInfoBase directoryInfo) {
    final rootPath = directoryInfo.fullName;
    final matches = <FilePatternMatch>[];
    final matchedPaths = <String>{};

    // Process include patterns
    for (final pattern in _includePatterns) {
      final glob = Glob(pattern);

      try {
        // List all files recursively from the root
        final rootDir = Directory(rootPath);
        if (!rootDir.existsSync()) {
          continue;
        }

        final entities = rootDir.listSync(recursive: true, followLinks: false);

        for (final entity in entities) {
          if (entity is File) {
            try {
              final relativePath = p.relative(entity.path, from: rootPath);

              // Check if the file matches the include pattern
              if (glob.matches(relativePath)) {
                // Check against exclude patterns
                if (!_isExcluded(relativePath)) {
                  // Avoid duplicates
                  if (matchedPaths.add(relativePath)) {
                    matches.add(FilePatternMatch(
                      relativePath,
                      _calculateStem(pattern, relativePath),
                    ));
                  }
                }
              }
            } catch (e) {
              // Skip files we can't access
            }
          }
        }
      } catch (e) {
        // Skip patterns that fail to process
      }
    }

    return PatternMatchingResult(matches);
  }

  bool _isExcluded(String relativePath) {
    for (final pattern in _excludePatterns) {
      final glob = Glob(pattern);
      if (glob.matches(relativePath)) {
        return true;
      }
    }
    return false;
  }

  String? _calculateStem(String pattern, String matchedPath) {
    // Find the first wildcard in the pattern
    final wildcardIndex = _findFirstWildcardIndex(pattern);

    if (wildcardIndex == -1) {
      // No wildcard, return null
      return null;
    }

    // Get the pattern up to the wildcard
    final patternPrefix = pattern.substring(0, wildcardIndex);

    // Find the last directory separator before the wildcard
    final lastSepIndex = patternPrefix.lastIndexOf('/');

    if (lastSepIndex == -1) {
      // Wildcard is in the root, stem is the whole match
      return matchedPath;
    }

    // Calculate the stem relative to the wildcard position
    final prefixDirs = patternPrefix.substring(0, lastSepIndex + 1);
    if (matchedPath.startsWith(prefixDirs)) {
      return matchedPath.substring(prefixDirs.length);
    }

    return matchedPath;
  }

  int _findFirstWildcardIndex(String pattern) {
    final wildcards = ['*', '?', '[', '{'];
    for (final wildcard in wildcards) {
      final index = pattern.indexOf(wildcard);
      if (index != -1) {
        return index;
      }
    }
    return -1;
  }
}

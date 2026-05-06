import 'dart:io';

import 'package:extensions/file_system_globbing.dart';
import 'package:file/local.dart';

/// This example demonstrates the file_system_globbing functionality,
/// which provides glob pattern matching for file system operations.
///
/// The globbing library is inspired by .NET's file globbing and supports:
/// - Wildcard patterns (*, ?, [...])
/// - Recursive directory matching (**)
/// - Include/exclude patterns
/// - In-memory file system matching
/// - File system abstraction for testability
void main() {
  print('=== File System Globbing Examples ===');

  _basicGlobbingExample();
  _advancedPatternsExample();
  _excludePatternsExample();
  _inMemoryMatchingExample();
  _matchWithoutFileSystemExample();
  _stemCalculationExample();
  _realWorldExample();
}

/// Example 1: Basic glob pattern matching
void _basicGlobbingExample() {
  print('\n--- Example 1: Basic Glob Pattern Matching ---');

  // Create a matcher with simple patterns
  final matcher = Matcher()
    ..addInclude('*.dart'); // Match all Dart files in current directory

  // Execute against the example directory
  final exampleDir =
      const LocalFileSystem().directory('packages/extensions/example');

  if (exampleDir.existsSync()) {
    final result = matcher.execute(DirectoryInfoWrapper(exampleDir));

    print('Found ${result.files.length} Dart files in example directory:');
    for (final match in result.files) {
      print('  - ${match.path}');
    }
  }

  print('');
}

/// Example 2: Advanced glob patterns
void _advancedPatternsExample() {
  print('--- Example 2: Advanced Glob Patterns ---');

  // Create a matcher with multiple patterns
  final matcher = Matcher()
    // Recursive: find all .dart files in any subdirectory
    ..addInclude('**/*.dart')
    // Find specific file types in specific directories
    ..addInclude('lib/**/*.dart')
    ..addInclude('test/**/*.dart');

  // Use the convenience extension to get full paths
  final projectDir = Directory.current.path;
  final fullPaths = matcher.getResultsInFullPath(projectDir);

  print('Found ${fullPaths.length} Dart files in project:');

  // Show first 10 matches
  for (final path in fullPaths.take(10)) {
    print('  - $path');
  }

  if (fullPaths.length > 10) {
    print('  ... and ${fullPaths.length - 10} more files');
  }

  print('');
}

/// Example 3: Using exclude patterns
void _excludePatternsExample() {
  print('--- Example 3: Include/Exclude Patterns ---');

  // Create a matcher that includes Dart files but excludes generated ones
  final matcher = Matcher()
    // Include all Dart files
    ..addInclude('**/*.dart')
    // Exclude generated files
    ..addExclude('**/*.g.dart')
    ..addExclude('**/*.freezed.dart')
    // Exclude test files
    ..addExclude('**/test/**')
    // Exclude build artifacts
    ..addExclude('**/build/**');

  final projectDir = Directory.current.path;
  final fullPaths = matcher.getResultsInFullPath(projectDir);

  print(
    'Found ${fullPaths.length} Dart files with exclude patterns applied:',
  );

  // Filter and show only lib files for clearer demonstration
  final libFiles = fullPaths.where((path) => path.contains('/lib/')).take(10);

  print('\nSample lib files (non-generated):');
  for (final path in libFiles) {
    print('  - $path');
  }

  if (fullPaths.length > 10) {
    print('  ... and ${fullPaths.length - 10} more files');
  }

  print('');
}

/// Example 4: In-memory directory structures
void _inMemoryMatchingExample() {
  print('--- Example 4: In-Memory Directory Structures ---');

  // The InMemoryDirectoryInfo and InMemoryFileInfo classes allow you
  // to create virtual file system structures for testing or abstraction.
  // Note: The current Matcher.execute() implementation uses the real file
  // system, but these classes are useful for testing file provider logic.

  // Create an in-memory file system structure
  // Build from the bottom up: create files and directories with their children

  // Create src directory with files
  final srcDir = InMemoryDirectoryInfo(
    '/src',
    files: [
      InMemoryFileInfo('/src/main.dart'),
      InMemoryFileInfo('/src/app.dart'),
      InMemoryFileInfo('/src/config.json'),
    ],
  );

  // Create lib directory with files
  final libDir = InMemoryDirectoryInfo(
    '/lib',
    files: [
      InMemoryFileInfo('/lib/utils.dart'),
      InMemoryFileInfo('/lib/models.dart'),
    ],
  );

  // Create test directory with files
  final testDir = InMemoryDirectoryInfo(
    '/test',
    files: [
      InMemoryFileInfo('/test/main_test.dart'),
      InMemoryFileInfo('/test/app_test.dart'),
    ],
  );

  // Create root directory with all subdirectories
  final rootDir = InMemoryDirectoryInfo(
    '/',
    files: [srcDir, libDir, testDir],
  );

  print('Created in-memory file system structure:');
  print('  /${rootDir.name}');
  for (final child in rootDir.enumerateFileSystemInfos()) {
    print('    ${child.name}/');
    if (child is InMemoryDirectoryInfo) {
      for (final file in child.enumerateFileSystemInfos()) {
        print('      ${file.name}');
      }
    }
  }

  print(
    '\nNote: These structures are useful for testing file provider',
  );
  print('logic without accessing the actual file system.');

  print('');
}

/// Example 5: Match files without accessing file system
void _matchWithoutFileSystemExample() {
  print('--- Example 5: Match Without File System Access ---');

  // Create a matcher for Dart source files, excluding tests
  final matcher = Matcher()
    ..addInclude('lib/**/*.dart')
    ..addInclude('src/**/*.dart')
    ..addExclude('**/*.g.dart')
    ..addExclude('**/test/**');

  // Match a single file path without accessing the file system
  final files = [
    '/project/lib/models/user.dart',
    '/project/lib/models/user.g.dart',
    '/project/src/utils/helpers.dart',
    '/project/test/models/user_test.dart',
    '/project/main.dart',
  ];

  print('Testing file paths against patterns:');
  for (final file in files) {
    final result = matcher.matchFile(file, '/project');
    final matches = result.hasFiles ? 'MATCH' : 'NO MATCH';
    final displayPath = file.substring('/project/'.length);
    print('  $matches - $displayPath');
  }

  print('');

  // Match multiple files at once
  final multiResult = matcher.matchFiles(files, '/project');
  print('Matched ${multiResult.files.length} files from the list:');
  for (final match in multiResult.files) {
    print('  - ${match.path}');
  }

  print('');
}

/// Example 6: Understanding stem calculation
void _stemCalculationExample() {
  print('--- Example 6: Stem Calculation ---');

  // Stem is the subpath relative to the first wildcard in the pattern
  final matcher = Matcher()
    ..addInclude('src/**/*.dart') // First wildcard at 'src/'
    ..addInclude('lib/models/**/*.dart'); // First wildcard at 'lib/models/'

  final files = [
    '/project/src/app/models/user.dart',
    '/project/src/utils/helpers.dart',
    '/project/lib/models/data/product.dart',
  ];

  print('File path -> stem (relative to first wildcard):');
  for (final file in files) {
    final result = matcher.matchFile(file, '/project');
    if (result.hasFiles) {
      final match = result.files.first;
      print('  ${match.path}');
      print('    -> stem: ${match.stem ?? "(null)"}');
    }
  }

  print('');
}

/// Example 7: Real-world use case - Finding source files for linting
void _realWorldExample() {
  print('--- Example 7: Real-World Use Case ---');
  print('Finding all source files for linting/analysis:\n');

  // Create a matcher that finds all source files but excludes:
  // - Generated files
  // - Test files
  // - Build artifacts
  // - Hidden directories
  final matcher = Matcher()
    // Include source files
    ..addInclude('lib/**/*.dart')
    ..addInclude('bin/**/*.dart')
    ..addInclude('tool/**/*.dart')
    // Exclude generated files
    ..addExclude('**/*.g.dart')
    ..addExclude('**/*.freezed.dart')
    ..addExclude('**/*.gr.dart')
    // Exclude test files
    ..addExclude('**/test/**')
    ..addExclude('**/*_test.dart')
    // Exclude build artifacts
    ..addExclude('**/build/**')
    ..addExclude('**/.dart_tool/**')
    // Exclude hidden directories
    ..addExclude('**/.*/**');

  final projectDir = Directory.current.path;
  final fullPaths = matcher.getResultsInFullPath(projectDir);

  print('Files to lint: ${fullPaths.length}');
  print('\nSample files:');
  for (final path in fullPaths.take(5)) {
    print('  - $path');
  }

  if (fullPaths.length > 5) {
    print('  ... and ${fullPaths.length - 5} more files');
  }

  print('\n--- Summary ---');
  print('The Matcher class provides powerful glob pattern matching:');
  print('  - Include/exclude patterns for flexible filtering');
  print('  - Recursive directory matching with **');
  print('  - Works with real or in-memory file systems');
  print('  - Can match without file system access');
  print('  - Calculates stems for relative path handling');
  print('  - Prevents duplicate matches automatically');
}

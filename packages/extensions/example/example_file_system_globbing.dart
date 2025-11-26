import 'dart:io' as io;

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
Future<void> main() async {
  io.stdout.writeln('=== File System Globbing Examples ===\n');

  await _basicGlobbingExample();
  await _advancedPatternsExample();
  await _excludePatternsExample();
  await _inMemoryMatchingExample();
  await _matchWithoutFileSystemExample();
  await _stemCalculationExample();
  await _realWorldExample();
}

/// Example 1: Basic glob pattern matching
Future<void> _basicGlobbingExample() async {
  io.stdout.writeln('--- Example 1: Basic Glob Pattern Matching ---');

  // Create a matcher with simple patterns
  final matcher = Matcher()
    ..addInclude('*.dart'); // Match all Dart files in current directory

  // Execute against the example directory
  final exampleDir =
      const LocalFileSystem().directory('packages/extensions/example');

  if (exampleDir.existsSync()) {
    final result = matcher.execute(DirectoryInfoWrapper(exampleDir));

    io.stdout.writeln(
      'Found ${result.files.length} Dart files in example directory:',
    );
    for (final match in result.files) {
      io.stdout.writeln('  - ${match.path}');
    }
  }

  io.stdout.writeln();
}

/// Example 2: Advanced glob patterns
Future<void> _advancedPatternsExample() async {
  io.stdout.writeln('--- Example 2: Advanced Glob Patterns ---');

  // Create a matcher with multiple patterns
  final matcher = Matcher()
    // Recursive: find all .dart files in any subdirectory
    ..addInclude('**/*.dart')
    // Find specific file types in specific directories
    ..addInclude('lib/**/*.dart')
    ..addInclude('test/**/*.dart');

  // Use the convenience extension to get full paths
  final projectDir = io.Directory.current.path;
  final fullPaths = matcher.getResultsInFullPath(projectDir);

  io.stdout.writeln('Found ${fullPaths.length} Dart files in project:');

  // Show first 10 matches
  for (final path in fullPaths.take(10)) {
    io.stdout.writeln('  - $path');
  }

  if (fullPaths.length > 10) {
    io.stdout.writeln('  ... and ${fullPaths.length - 10} more files');
  }

  io.stdout.writeln();
}

/// Example 3: Using exclude patterns
Future<void> _excludePatternsExample() async {
  io.stdout.writeln('--- Example 3: Include/Exclude Patterns ---');

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

  final projectDir = io.Directory.current.path;
  final fullPaths = matcher.getResultsInFullPath(projectDir);

  io.stdout.writeln(
    'Found ${fullPaths.length} Dart files with exclude patterns applied:',
  );

  // Filter and show only lib files for clearer demonstration
  final libFiles = fullPaths.where((path) => path.contains('/lib/')).take(10);

  io.stdout.writeln('\nSample lib files (non-generated):');
  for (final path in libFiles) {
    io.stdout.writeln('  - $path');
  }

  if (fullPaths.length > 10) {
    io.stdout.writeln('  ... and ${fullPaths.length - 10} more files');
  }

  io.stdout.writeln();
}

/// Example 4: In-memory directory structures
Future<void> _inMemoryMatchingExample() async {
  io.stdout.writeln('--- Example 4: In-Memory Directory Structures ---');

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

  io.stdout.writeln('Created in-memory file system structure:');
  io.stdout.writeln('  /${rootDir.name}');
  for (final child in rootDir.enumerateFileSystemInfos()) {
    io.stdout.writeln('    ${child.name}/');
    if (child is InMemoryDirectoryInfo) {
      for (final file in child.enumerateFileSystemInfos()) {
        io.stdout.writeln('      ${file.name}');
      }
    }
  }

  io.stdout.writeln(
    '\nNote: These structures are useful for testing file provider',
  );
  io.stdout.writeln('logic without accessing the actual file system.');

  io.stdout.writeln();
}

/// Example 5: Match files without accessing file system
Future<void> _matchWithoutFileSystemExample() async {
  io.stdout.writeln('--- Example 5: Match Without File System Access ---');

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

  io.stdout.writeln('Testing file paths against patterns:');
  for (final file in files) {
    final result = matcher.matchFile(file, '/project');
    final matches = result.hasFiles ? '✓ MATCH' : '✗ NO MATCH';
    final displayPath = file.substring('/project/'.length);
    io.stdout.writeln('  $matches - $displayPath');
  }

  io.stdout.writeln();

  // Match multiple files at once
  final multiResult = matcher.matchFiles(files, '/project');
  io.stdout.writeln('Matched ${multiResult.files.length} files from the list:');
  for (final match in multiResult.files) {
    io.stdout.writeln('  - ${match.path}');
  }

  io.stdout.writeln();
}

/// Example 6: Understanding stem calculation
Future<void> _stemCalculationExample() async {
  io.stdout.writeln('--- Example 6: Stem Calculation ---');

  // Stem is the subpath relative to the first wildcard in the pattern
  final matcher = Matcher()
    ..addInclude('src/**/*.dart') // First wildcard at 'src/'
    ..addInclude('lib/models/**/*.dart'); // First wildcard at 'lib/models/'

  final files = [
    '/project/src/app/models/user.dart',
    '/project/src/utils/helpers.dart',
    '/project/lib/models/data/product.dart',
  ];

  io.stdout.writeln('File path → Stem (relative to first wildcard):');
  for (final file in files) {
    final result = matcher.matchFile(file, '/project');
    if (result.hasFiles) {
      final match = result.files.first;
      io.stdout.writeln('  ${match.path}');
      io.stdout.writeln('    → stem: ${match.stem ?? "(null)"}');
    }
  }

  io.stdout.writeln();
}

/// Example 7: Real-world use case - Finding source files for linting
Future<void> _realWorldExample() async {
  io.stdout.writeln('--- Example 7: Real-World Use Case ---');
  io.stdout.writeln('Finding all source files for linting/analysis:\n');

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

  final projectDir = io.Directory.current.path;
  final fullPaths = matcher.getResultsInFullPath(projectDir);

  io.stdout.writeln('Files to lint: ${fullPaths.length}');
  io.stdout.writeln('\nSample files:');
  for (final path in fullPaths.take(5)) {
    io.stdout.writeln('  - $path');
  }

  if (fullPaths.length > 5) {
    io.stdout.writeln('  ... and ${fullPaths.length - 5} more files');
  }

  io.stdout.writeln('\n--- Summary ---');
  io.stdout
      .writeln('The Matcher class provides powerful glob pattern matching:');
  io.stdout.writeln('  • Include/exclude patterns for flexible filtering');
  io.stdout.writeln('  • Recursive directory matching with **');
  io.stdout.writeln('  • Works with real or in-memory file systems');
  io.stdout.writeln('  • Can match without file system access');
  io.stdout.writeln('  • Calculates stems for relative path handling');
  io.stdout.writeln('  • Prevents duplicate matches automatically');
}

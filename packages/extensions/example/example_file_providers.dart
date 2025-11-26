// ignore_for_file: avoid_print

import 'dart:io' as io;

import 'package:extensions/file_providers.dart';
import 'package:path/path.dart' as p;

/// Example demonstrating the FileProvider abstraction and implementations.
///
/// FileProviders provide a read-only file abstraction with change notification
/// support. This example demonstrates:
/// - PhysicalFileProvider for accessing files on disk
/// - CompositeFileProvider for combining multiple providers
/// - File change notifications using change tokens
/// - Directory enumeration
/// - Security features (path traversal protection)
/// - NullFileProvider usage
void main() async {
  print('=== FileProvider Examples ===\n');

  // Example 1: Basic PhysicalFileProvider usage
  await basicPhysicalFileProviderExample();

  print('\n${'=' * 50}\n');

  // Example 2: Watching for file changes
  await fileChangeNotificationExample();

  print('\n${'=' * 50}\n');

  // Example 3: Composite file provider
  await compositeFileProviderExample();

  print('\n${'=' * 50}\n');

  // Example 4: Directory enumeration
  await directoryEnumerationExample();

  print('\n${'=' * 50}\n');

  // Example 5: Security and path validation
  await securityExample();

  print('\n${'=' * 50}\n');

  // Example 6: NullFileProvider usage
  nullFileProviderExample();
}

/// Example 1: Basic PhysicalFileProvider usage
Future<void> basicPhysicalFileProviderExample() async {
  print('Example 1: Basic PhysicalFileProvider Usage');
  print('-' * 50);

  // Create a temporary directory for demonstration
  final tempDir = io.Directory.systemTemp.createTempSync('file_provider_ex1_');
  final rootPath = tempDir.path;

  try {
    // Create some test files
    final testFile = io.File(p.join(rootPath, 'example.txt'));
    await testFile.writeAsString('Hello, FileProvider!');

    // Create a PhysicalFileProvider pointing to the root directory
    final provider = PhysicalFileProvider(rootPath);

    print('Root directory: $rootPath\n');

    // Get information about a file
    final fileInfo = provider.getFileInfo('example.txt');

    print('File Information:');
    print('  Exists: ${fileInfo.exists}');
    print('  Name: ${fileInfo.name}');
    print('  Length: ${fileInfo.length} bytes');
    print('  Physical path: ${fileInfo.physicalPath}');
    print('  Last modified: ${fileInfo.lastModified}');
    print('  Is directory: ${fileInfo.isDirectory}');

    // Read file contents
    if (fileInfo.exists && !fileInfo.isDirectory) {
      final stream = fileInfo.createReadStream();
      final contents = await stream.toList();
      final bytes = <int>[];
      for (final chunk in contents) {
        bytes.addAll(chunk as List<int>);
      }
      final text = String.fromCharCodes(bytes);
      print('  Contents: $text');
    }

    // Check for non-existent file
    print('\nChecking non-existent file:');
    final missingFile = provider.getFileInfo('missing.txt');
    print('  missing.txt exists: ${missingFile.exists}');

    // Dispose the provider when done
    provider.dispose();
  } finally {
    // Clean up
    tempDir.deleteSync(recursive: true);
  }
}

/// Example 2: Watching for file changes
Future<void> fileChangeNotificationExample() async {
  print('Example 2: File Change Notification');
  print('-' * 50);

  final tempDir = io.Directory.systemTemp.createTempSync('file_provider_ex2_');
  final rootPath = tempDir.path;

  try {
    // Create initial file
    final testFile = io.File(p.join(rootPath, 'watched.txt'));
    await testFile.writeAsString('Initial content');

    // Use a short polling interval for demonstration purposes
    final provider = PhysicalFileProvider(
      rootPath,
      options: PhysicalFileProviderOptions(
        pollingInterval: const Duration(milliseconds: 500),
      ),
    );

    // Create a change token to watch for changes to .txt files
    final changeToken = provider.watch('*.txt');

    print('Watching for changes to *.txt files...');
    print('Has changed (before): ${changeToken.hasChanged}');

    // Register a callback for when changes occur
    var changeDetected = false;
    changeToken.registerChangeCallback((_) {
      print('\n🔔 Change detected in *.txt files!');
      changeDetected = true;
    }, null);

    // Give the file watcher time to initialize
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // Wait for the file system timestamp to advance (most file systems
    // have 1-second precision for modification times)
    print('\nWaiting for file system timestamp to advance...');
    await Future<void>.delayed(const Duration(milliseconds: 1100));

    // Modify the file
    print('Modifying watched.txt...');
    await testFile.writeAsString('Updated content');

    // Wait for change notification (polling interval + buffer time)
    await Future<void>.delayed(const Duration(milliseconds: 800));

    print('Has changed (after): ${changeToken.hasChanged}');
    print('Change callback fired: $changeDetected');

    provider.dispose();
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}

/// Example 3: Composite file provider
Future<void> compositeFileProviderExample() async {
  print('Example 3: CompositeFileProvider');
  print('-' * 50);

  final tempDir1 = io.Directory.systemTemp.createTempSync('provider1_');
  final tempDir2 = io.Directory.systemTemp.createTempSync('provider2_');

  try {
    // Create files in first provider
    await io.File(p.join(tempDir1.path, 'shared.txt'))
        .writeAsString('From provider 1');
    await io.File(p.join(tempDir1.path, 'unique1.txt'))
        .writeAsString('Only in provider 1');

    // Create files in second provider
    await io.File(p.join(tempDir2.path, 'shared.txt'))
        .writeAsString('From provider 2');
    await io.File(p.join(tempDir2.path, 'unique2.txt'))
        .writeAsString('Only in provider 2');

    // Create two physical file providers
    final provider1 = PhysicalFileProvider(tempDir1.path);
    final provider2 = PhysicalFileProvider(tempDir2.path);

    // Combine them with a composite provider
    final composite = CompositeFileProvider([provider1, provider2]);

    print('Composite provider combines multiple file sources.\n');

    // First-found-wins: provider1's shared.txt will be used
    final sharedFile = composite.getFileInfo('shared.txt');
    print('Getting shared.txt (first-found-wins):');
    if (sharedFile.exists) {
      final stream = sharedFile.createReadStream();
      final contents = await stream.toList();
      final bytes = <int>[];
      for (final chunk in contents) {
        bytes.addAll(chunk as List<int>);
      }
      final text = String.fromCharCodes(bytes);
      print('  Content: $text');
    }

    // Access unique files from each provider
    final unique1 = composite.getFileInfo('unique1.txt');
    print('\nGetting unique1.txt:');
    print('  Exists: ${unique1.exists}');

    final unique2 = composite.getFileInfo('unique2.txt');
    print('\nGetting unique2.txt:');
    print('  Exists: ${unique2.exists}');

    // Directory contents are merged from all providers
    print('\nDirectory contents (merged from all providers):');
    final contents = composite.getDirectoryContents('/');
    if (contents.exists) {
      for (final file in contents) {
        print('  - ${file.name}');
      }
    }

    provider1.dispose();
    provider2.dispose();
  } finally {
    tempDir1.deleteSync(recursive: true);
    tempDir2.deleteSync(recursive: true);
  }
}

/// Example 4: Directory enumeration
Future<void> directoryEnumerationExample() async {
  print('Example 4: Directory Enumeration');
  print('-' * 50);

  final tempDir = io.Directory.systemTemp.createTempSync('file_provider_ex4_');
  final rootPath = tempDir.path;

  try {
    // Create directory structure
    final subDir = io.Directory(p.join(rootPath, 'documents'));
    await subDir.create();

    await io.File(p.join(rootPath, 'root.txt')).writeAsString('Root file');
    await io.File(p.join(subDir.path, 'doc1.txt')).writeAsString('Document 1');
    await io.File(p.join(subDir.path, 'doc2.txt')).writeAsString('Document 2');

    final provider = PhysicalFileProvider(rootPath);

    // List root directory contents
    print('Root directory contents:');
    final rootContents = provider.getDirectoryContents('/');
    print('  Exists: ${rootContents.exists}');
    for (final item in rootContents) {
      final type = item.isDirectory ? '[DIR]' : '[FILE]';
      print('  $type ${item.name}');
    }

    // List subdirectory contents
    print('\nDocuments directory contents:');
    final docsContents = provider.getDirectoryContents('/documents');
    for (final item in docsContents) {
      final type = item.isDirectory ? '[DIR]' : '[FILE]';
      print('  $type ${item.name} (${item.length} bytes)');
    }

    // Non-existent directory
    print('\nNon-existent directory:');
    final missingContents = provider.getDirectoryContents('/missing');
    print('  Exists: ${missingContents.exists}');
    if (missingContents.exists) {
      print('  Item count: ${missingContents.length}');
    } else {
      print('  (Directory does not exist)');
    }

    provider.dispose();
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}

/// Example 5: Security and path validation
Future<void> securityExample() async {
  print('Example 5: Security and Path Validation');
  print('-' * 50);

  final tempDir = io.Directory.systemTemp.createTempSync('file_provider_ex5_');
  final rootPath = tempDir.path;

  try {
    // Create a file in the root
    await io.File(p.join(rootPath, 'allowed.txt'))
        .writeAsString('Accessible file');

    // Create a file outside the root (simulating an attack)
    final outsideFile = io.File(p.join(tempDir.parent.path, 'outside.txt'));
    await outsideFile.writeAsString('Should not be accessible');

    final provider = PhysicalFileProvider(rootPath);

    print('Root path: $rootPath\n');

    // Safe access - file within root
    print('Accessing file within root:');
    final safeFile = provider.getFileInfo('allowed.txt');
    print('  allowed.txt exists: ${safeFile.exists}');

    // Attempted path traversal attacks
    print('\nAttempted path traversal attacks:');
    final attackPaths = [
      '../outside.txt',
      '../../outside.txt',
      '../../../outside.txt',
    ];

    for (final attackPath in attackPaths) {
      final attackFile = provider.getFileInfo(attackPath);
      print('  $attackPath exists: ${attackFile.exists}');
    }

    print('\n✓ PhysicalFileProvider protects against path traversal attacks');

    // Exclusion filters example
    print('\nExclusion filters (configured in options):');
    print('  Default filters exclude sensitive files like:');
    print('  - Hidden files (starting with .)');
    print('  - System files');
    print('  - Files in hidden directories');

    // Example with custom options
    final providerWithOptions = PhysicalFileProvider(
      rootPath,
      options: PhysicalFileProviderOptions(
        exclusionFilters: ExclusionFilters.sensitive,
        usePollingFileWatcher: false,
      ),
    );
    print('\nCreated provider with custom options:');
    print('  - Exclusion filters: ExclusionFilters.sensitive');
    print('  - Use polling file watcher: false');

    provider.dispose();
    providerWithOptions.dispose();

    // Clean up outside file
    if (await outsideFile.exists()) {
      await outsideFile.delete();
    }
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}

/// Example 6: NullFileProvider usage
void nullFileProviderExample() {
  print('Example 6: NullFileProvider');
  print('-' * 50);

  // NullFileProvider is an empty provider with no contents
  final provider = NullFileProvider();

  print('NullFileProvider always returns not-found results.\n');

  // Try to get a file (will not exist)
  final fileInfo = provider.getFileInfo('any-file.txt');
  print('File exists: ${fileInfo.exists}');
  print('File name: ${fileInfo.name}');

  // Try to get directory contents (will be empty)
  final contents = provider.getDirectoryContents('/');
  print('\nDirectory exists: ${contents.exists}');
  print('Directory item count: ${contents.length}');

  // Watch for changes (token will never fire)
  final changeToken = provider.watch('*.*');
  print(
    '\nChange token active callbacks: '
    '${changeToken.activeChangeCallbacks}',
  );
  print('Change token has changed: ${changeToken.hasChanged}');

  print('\nNullFileProvider is useful for:');
  print('  - Testing scenarios where no files should be found');
  print('  - Default/fallback provider when no real provider is configured');
  print('  - Null object pattern implementation');
}

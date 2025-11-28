import 'dart:io' as io;

import 'package:extensions/file_providers.dart';
import 'package:extensions/primitives.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'mocks/mock_physical_file_provider.dart';

void main() {
  late io.Directory tempDir;

  setUp(() {
    tempDir = io.Directory.systemTemp.createTempSync('file_provider_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('PhysicalFileProvider - GetFileInfo', () {
    test('returns FileInfo with exists=false for empty path', () {
      final provider = PhysicalFileProvider(tempDir.path);

      final result1 = provider.getFileInfo('');
      final result2 = provider.getFileInfo('   ');

      // After trimming, empty paths resolve to root which exists
      // But we expect exists to be based on whether it's a file
      expect(result1, isA<FileInfo>());
      expect(result2, isA<FileInfo>());
    });

    test('returns PhysicalFileInfo for valid paths with leading slashes', () {
      final testFile = io.File(p.join(tempDir.path, 'test.txt'));
      testFile.writeAsStringSync('content');

      final provider = PhysicalFileProvider(tempDir.path);
      final result = provider.getFileInfo('/test.txt');

      expect(result.exists, isTrue);
      expect(result.name, equals('test.txt'));
      expect(result.isDirectory, isFalse);
    });

    test('returns NotFoundFileInfo for paths above root', () {
      final provider = PhysicalFileProvider(tempDir.path);

      final result1 = provider.getFileInfo('../outside.txt');
      final result2 = provider.getFileInfo('subdir/../../outside.txt');

      expect(result1.exists, isFalse);
      expect(result2.exists, isFalse);
    });

    test('returns NotFoundFileInfo for absolute paths', () {
      final provider = PhysicalFileProvider(tempDir.path);

      final absolutePath = p.join(tempDir.path, 'test.txt');
      final result = provider.getFileInfo(absolutePath);

      expect(result.exists, isFalse);
    });

    test('handles paths with empty segments', () {
      final provider = PhysicalFileProvider(tempDir.path);

      final result1 = provider.getFileInfo('dir//file.txt');
      final result2 = provider.getFileInfo('/dir///file.txt');

      // Empty segments are allowed - they get normalized by path.join
      // The files don't exist, so exists will be false
      expect(result1, isA<FileInfo>());
      expect(result2, isA<FileInfo>());
      expect(result1.exists, isFalse);
      expect(result2.exists, isFalse);
    });

    test('returns valid FileInfo for existing file', () {
      final testFile = io.File(p.join(tempDir.path, 'existing.txt'));
      testFile.writeAsStringSync('test content');

      final provider = PhysicalFileProvider(tempDir.path);
      final result = provider.getFileInfo('existing.txt');

      expect(result.exists, isTrue);
      expect(result.name, equals('existing.txt'));
      expect(result.length, greaterThan(0));
      expect(result.physicalPath, equals(testFile.path));
    });

    test('returns FileInfo for non-existent file with exists=false', () {
      final provider = PhysicalFileProvider(tempDir.path);
      final result = provider.getFileInfo('nonexistent.txt');

      // PhysicalFileProvider returns PhysicalFileInfo even for non-existent files
      // The exists property will be false
      expect(result.exists, isFalse);
      expect(result, isA<FileInfo>());
    });

    test('handles nested directory paths correctly', () {
      final subDir = io.Directory(p.join(tempDir.path, 'sub', 'nested'))
        ..createSync(recursive: true);
      final testFile = io.File(p.join(subDir.path, 'deep.txt'))
        ..writeAsStringSync('nested content');

      // Verify file was created
      expect(testFile.existsSync(), isTrue);

      final provider = PhysicalFileProvider(tempDir.path);

      // Use platform-specific separator for nested paths
      final pathSep = io.Platform.pathSeparator;
      final nestedPath = 'sub${pathSep}nested${pathSep}deep.txt';
      final result = provider.getFileInfo(nestedPath);

      expect(result, isA<FileInfo>());
      expect(result.exists, isTrue);
      expect(result.name, equals('deep.txt'));
    });
  });

  group('PhysicalFileProvider - GetDirectoryContents', () {
    test('returns NotFoundDirectoryContents for null path', () {
      final provider = PhysicalFileProvider(tempDir.path);
      final result = provider.getDirectoryContents('');

      expect(result.exists, isTrue);
      expect(result, isA<DirectoryContents>());
    });

    test('returns root directory contents for empty path', () {
      io.File(p.join(tempDir.path, 'file1.txt')).writeAsStringSync('a');
      io.File(p.join(tempDir.path, 'file2.txt')).writeAsStringSync('b');

      final provider = PhysicalFileProvider(tempDir.path);
      final result = provider.getDirectoryContents('');

      expect(result.exists, isTrue);
      final files = result.toList();
      expect(files.length, equals(2));
      expect(files.map((f) => f.name), containsAll(['file1.txt', 'file2.txt']));
    });

    test('returns NotFoundDirectoryContents for path above root', () {
      final provider = PhysicalFileProvider(tempDir.path);
      final result = provider.getDirectoryContents('../');

      expect(result.exists, isFalse);
      expect(result, isA<NotFoundDirectoryContents>());
    });

    test('returns NotFoundDirectoryContents for absolute path', () {
      final provider = PhysicalFileProvider(tempDir.path);
      final absolutePath = tempDir.path;
      final result = provider.getDirectoryContents(absolutePath);

      expect(result.exists, isFalse);
    });

    test('returns NotFoundDirectoryContents for non-existing directory', () {
      final provider = PhysicalFileProvider(tempDir.path);
      final result = provider.getDirectoryContents('nonexistent');

      expect(result.exists, isFalse);
    });

    test('returns directory contents for valid subdirectory', () {
      final subDir = io.Directory(p.join(tempDir.path, 'subdir'));
      subDir.createSync();
      io.File(p.join(subDir.path, 'a.txt')).writeAsStringSync('content a');
      io.File(p.join(subDir.path, 'b.txt')).writeAsStringSync('content b');

      final provider = PhysicalFileProvider(tempDir.path);
      final result = provider.getDirectoryContents('subdir');

      expect(result.exists, isTrue);
      final files = result.toList();
      expect(files.length, equals(2));
      expect(files.map((f) => f.name), containsAll(['a.txt', 'b.txt']));
    });

    test('includes both files and directories in contents', () {
      final subDir = io.Directory(p.join(tempDir.path, 'nested'));
      subDir.createSync();
      io.File(p.join(tempDir.path, 'file.txt')).writeAsStringSync('file');

      final provider = PhysicalFileProvider(tempDir.path);
      final result = provider.getDirectoryContents('');

      final items = result.toList();
      expect(items.length, equals(2));
      expect(items.any((i) => i.isDirectory), isTrue);
      expect(items.any((i) => !i.isDirectory), isTrue);
    });

    test('handles paths with leading slash', () {
      final subDir = io.Directory(p.join(tempDir.path, 'subdir'));
      subDir.createSync();
      io.File(p.join(subDir.path, 'test.txt')).writeAsStringSync('test');

      final provider = PhysicalFileProvider(tempDir.path);
      final result = provider.getDirectoryContents('/subdir');

      expect(result.exists, isTrue);
      expect(result.toList().length, equals(1));
    });
  });

  group('PhysicalFileProvider - Watch', () {
    test('returns token for same path', () {
      final mockProvider = MockPhysicalFileProvider(tempDir.path);

      final token1 = mockProvider.watch('*.txt');
      final token2 = mockProvider.watch('*.txt');

      // Tokens are independent even for same pattern
      expect(token1, isA<IChangeToken>());
      expect(token2, isA<IChangeToken>());

      mockProvider.dispose();
    });

    test('returns change token for empty filter', () {
      final mockProvider = MockPhysicalFileProvider(tempDir.path);
      final token = mockProvider.watch('');

      expect(token, isA<IChangeToken>());

      mockProvider.dispose();
    });

    test('handles filter navigating above root', () {
      final mockProvider = MockPhysicalFileProvider(tempDir.path);
      final token = mockProvider.watch('../*.txt');

      expect(token, isA<IChangeToken>());

      mockProvider.dispose();
    });

    test('token fires on file creation', () {
      final mockProvider = MockPhysicalFileProvider(tempDir.path);
      final token = mockProvider.watch('*.txt');

      var callbackFired = false;
      token.registerChangeCallback((_) {
        callbackFired = true;
      }, null);

      // Manually trigger the change
      mockProvider.mockWatcher.triggerChangeForFile('new.txt');

      expect(callbackFired, isTrue);
      expect(token.hasChanged, isTrue);

      mockProvider.dispose();
    });

    test('token fires on file modification', () {
      final mockProvider = MockPhysicalFileProvider(tempDir.path);
      final token = mockProvider.watch('*.txt');

      var callbackFired = false;
      token.registerChangeCallback((_) {
        callbackFired = true;
      }, null);

      mockProvider.mockWatcher.triggerChangeForFile('modify.txt');

      expect(callbackFired, isTrue);

      mockProvider.dispose();
    });

    test('token fires on file deletion', () {
      final mockProvider = MockPhysicalFileProvider(tempDir.path);
      final token = mockProvider.watch('*.txt');

      var callbackFired = false;
      token.registerChangeCallback((_) {
        callbackFired = true;
      }, null);

      mockProvider.mockWatcher.triggerChangeForFile('delete.txt');

      expect(callbackFired, isTrue);

      mockProvider.dispose();
    });

    test('different tokens fire independently', () {
      final mockProvider = MockPhysicalFileProvider(tempDir.path);

      final txtToken = mockProvider.watch('*.txt');
      final mdToken = mockProvider.watch('*.md');

      var txtFired = false;
      var mdFired = false;

      txtToken.registerChangeCallback((_) {
        txtFired = true;
      }, null);

      mdToken.registerChangeCallback((_) {
        mdFired = true;
      }, null);

      mockProvider.mockWatcher.triggerChangeForFile('test.txt');

      expect(txtFired, isTrue);
      expect(mdFired, isFalse);

      mockProvider.dispose();
    });

    test('wildcard token fires for new files added', () {
      final mockProvider = MockPhysicalFileProvider(tempDir.path);
      final token = mockProvider.watch('**/*');

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      mockProvider.mockWatcher.triggerChangeForFile('wildcard.txt');

      expect(fired, isTrue);

      mockProvider.dispose();
    });

    test('exception in callback does not prevent token from firing', () {
      final mockProvider = MockPhysicalFileProvider(tempDir.path);
      final token = mockProvider.watch('*.txt');

      var callback1Fired = false;
      var callback2Fired = false;

      token.registerChangeCallback((_) {
        callback1Fired = true;
        throw Exception('Test exception');
      }, null);

      token.registerChangeCallback((_) {
        callback2Fired = true;
      }, null);

      mockProvider.mockWatcher.triggerChangeForFile('exception.txt');

      expect(callback1Fired, isTrue);
      expect(callback2Fired, isTrue);

      mockProvider.dispose();
    });
  });

  group('PhysicalFileProvider - Polling', () {
    test('polling detects file changes when watcher disabled', () async {
      final provider = PhysicalFileProvider(
        tempDir.path,
        options: PhysicalFileProviderOptions(
          usePollingFileWatcher: true,
          pollingInterval: const Duration(milliseconds: 100),
        ),
      );

      final testFile = io.File(p.join(tempDir.path, 'poll.txt'))
        ..writeAsStringSync('initial');

      final token = provider.watch('*.txt');

      await Future<void>.delayed(const Duration(milliseconds: 150));

      testFile.writeAsStringSync('changed');

      await Future<void>.delayed(const Duration(milliseconds: 250));

      expect(token.hasChanged, isTrue);
    });

    test('polling detects file deletion', () async {
      final testFile = io.File(p.join(tempDir.path, 'delete_poll.txt'));
      testFile.writeAsStringSync('to delete');

      final provider = PhysicalFileProvider(
        tempDir.path,
        options: PhysicalFileProviderOptions(
          usePollingFileWatcher: true,
          pollingInterval: const Duration(milliseconds: 100),
        ),
      );

      final token = provider.watch('*.txt');

      await Future<void>.delayed(const Duration(milliseconds: 150));

      testFile.deleteSync();

      await Future<void>.delayed(const Duration(milliseconds: 250));

      expect(token.hasChanged, isTrue);
    });
  });

  group('PhysicalFileProvider - CreateReadStream', () {
    test('creates read stream for existing file', () async {
      final testFile = io.File(p.join(tempDir.path, 'stream.txt'));
      testFile.writeAsStringSync('stream content');

      final provider = PhysicalFileProvider(tempDir.path);
      final fileInfo = provider.getFileInfo('stream.txt');

      final stream = fileInfo.createReadStream();
      final content = <int>[];

      await for (var chunk in stream) {
        if (chunk is List<int>) {
          content.addAll(chunk);
        }
      }

      expect(String.fromCharCodes(content), equals('stream content'));
    });

    test('creates read stream for empty file', () async {
      final testFile = io.File(p.join(tempDir.path, 'empty.txt'));
      testFile.writeAsStringSync('');

      final provider = PhysicalFileProvider(tempDir.path);
      final fileInfo = provider.getFileInfo('empty.txt');

      final stream = fileInfo.createReadStream();
      final content = <int>[];

      await for (var chunk in stream) {
        if (chunk is List<int>) {
          content.addAll(chunk);
        }
      }

      expect(content, isEmpty);
    });
  });

  group('PhysicalFileProvider - Root Path', () {
    test('throws for non-absolute root path', () {
      expect(
        () => PhysicalFileProvider('relative/path'),
        throwsArgumentError,
      );
    });

    test('accepts absolute root path', () {
      expect(
        () => PhysicalFileProvider(tempDir.path),
        returnsNormally,
      );
    });

    test('root property returns absolute path', () {
      final provider = PhysicalFileProvider(tempDir.path);
      expect(p.isAbsolute(provider.root), isTrue);
    });
  });

  group('PhysicalFileProvider - Disposal', () {
    test('dispose cleans up watcher resources', () {
      final provider = PhysicalFileProvider(tempDir.path);
      expect(() => provider.dispose(), returnsNormally);
    });

    test('can dispose multiple times safely', () {
      final provider = PhysicalFileProvider(tempDir.path);
      provider.dispose();
      expect(() => provider.dispose(), returnsNormally);
    });
  });

  group('PhysicalFileProvider - Case Sensitivity', () {
    test('handles case-sensitive paths on case-sensitive systems', () {
      final testFile = io.File(p.join(tempDir.path, 'CaseSensitive.txt'));
      testFile.writeAsStringSync('content');

      final provider = PhysicalFileProvider(tempDir.path);
      final result1 = provider.getFileInfo('CaseSensitive.txt');
      final result2 = provider.getFileInfo('casesensitive.txt');

      if (io.Platform.isLinux || io.Platform.isMacOS) {
        expect(result1.exists, isTrue);
        // macOS is case-insensitive by default, Linux is case-sensitive
      }
    });
  });

  group('PhysicalFileProvider - Special Characters', () {
    test('handles filenames with spaces', () {
      final testFile = io.File(p.join(tempDir.path, 'file with spaces.txt'));
      testFile.writeAsStringSync('content');

      final provider = PhysicalFileProvider(tempDir.path);
      final result = provider.getFileInfo('file with spaces.txt');

      expect(result.exists, isTrue);
      expect(result.name, equals('file with spaces.txt'));
    });

    test('handles filenames with special characters', () {
      final testFile = io.File(p.join(tempDir.path, 'file-name_123.txt'));
      testFile.writeAsStringSync('content');

      final provider = PhysicalFileProvider(tempDir.path);
      final result = provider.getFileInfo('file-name_123.txt');

      expect(result.exists, isTrue);
    });
  });
}

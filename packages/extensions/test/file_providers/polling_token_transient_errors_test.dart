import 'dart:io' as io;

import 'package:extensions/file_providers.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// Mirrors upstream dotnet/runtime #132617: a transient file system failure
/// during polling must be reported as "no change" and retried on the next
/// poll, rather than firing a spurious change notification.
void main() {
  late io.Directory tempDir;

  setUp(() {
    tempDir = io.Directory.systemTemp.createTempSync('polling_transient_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('PollingWildcardChangeToken - transient file system errors', () {
    test('a failed scan reports no change instead of a removal', () async {
      // Arrange
      io.File(p.join(tempDir.path, 'a.txt')).writeAsStringSync('content');
      final root = _FlakyDirectory(
        const LocalFileSystem().directory(tempDir.path),
      );
      final token = PollingWildcardChangeToken(
        root,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 50),
      );

      // Act
      root.failing = true;
      await Future<void>.delayed(const Duration(milliseconds: 80));

      // Assert
      expect(token.hasChanged, isFalse);

      token.dispose();
    });

    test('a real change is still detected once the scan recovers', () async {
      // Arrange
      final file = io.File(p.join(tempDir.path, 'a.txt'))
        ..writeAsStringSync('content');
      final root = _FlakyDirectory(
        const LocalFileSystem().directory(tempDir.path),
      );
      final token = PollingWildcardChangeToken(
        root,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 50),
      );

      // Act
      root.failing = true;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(token.hasChanged, isFalse);

      file.writeAsStringSync('content changed');
      root.failing = false;
      await Future<void>.delayed(const Duration(milliseconds: 80));

      // Assert
      expect(token.hasChanged, isTrue);

      token.dispose();
    });

    test(
      'the first successful scan after a failed one is the baseline',
      () async {
        // Arrange
        io.File(p.join(tempDir.path, 'a.txt')).writeAsStringSync('content');
        final root = _FlakyDirectory(
          const LocalFileSystem().directory(tempDir.path),
        )..failing = true;

        // Act — the constructor's initial scan fails, so there is no baseline.
        final token = PollingWildcardChangeToken(
          root,
          '*.txt',
          pollingInterval: const Duration(milliseconds: 50),
        );
        root.failing = false;
        await Future<void>.delayed(const Duration(milliseconds: 80));

        // Assert — the first completed scan establishes the baseline and does
        // not count pre-existing files as additions.
        expect(token.hasChanged, isFalse);

        token.dispose();
      },
    );
  });

  group('PollingFileChangeToken - transient file system errors', () {
    test('a failed read reports no change', () async {
      // Arrange
      final path = p.join(tempDir.path, 'a.txt');
      io.File(path).writeAsStringSync('content');
      final file = _FlakyFile(const LocalFileSystem().file(path));
      final token = PollingFileChangeToken(
        file,
        pollingInterval: const Duration(milliseconds: 50),
      );

      // Act
      file.failing = true;
      await Future<void>.delayed(const Duration(milliseconds: 80));

      // Assert
      expect(token.hasChanged, isFalse);

      token.dispose();
    });

    test('a real change is still detected once the read recovers', () async {
      // Arrange
      final path = p.join(tempDir.path, 'a.txt');
      io.File(path).writeAsStringSync('content');
      final file = _FlakyFile(const LocalFileSystem().file(path));
      final token = PollingFileChangeToken(
        file,
        pollingInterval: const Duration(milliseconds: 50),
      );

      // Act
      file.failing = true;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(token.hasChanged, isFalse);

      io.File(path)
          .setLastModifiedSync(DateTime.now().add(const Duration(seconds: 5)));
      file.failing = false;
      await Future<void>.delayed(const Duration(milliseconds: 80));

      // Assert
      expect(token.hasChanged, isTrue);

      token.dispose();
    });
  });
}

/// A [Directory] that can be made to fail its listing on demand.
class _FlakyDirectory implements Directory {
  _FlakyDirectory(this._inner);

  final Directory _inner;

  /// When `true`, [listSync] throws as if the directory were inaccessible.
  bool failing = false;

  @override
  FileSystem get fileSystem => _inner.fileSystem;

  @override
  String get path => _inner.path;

  @override
  bool existsSync() => _inner.existsSync();

  @override
  List<FileSystemEntity> listSync({
    bool recursive = false,
    bool followLinks = true,
  }) {
    if (failing) {
      throw FileSystemException('Directory listing failed', _inner.path);
    }
    return _inner.listSync(recursive: recursive, followLinks: followLinks);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A [File] that can be made to fail its stat calls on demand.
class _FlakyFile implements File {
  _FlakyFile(this._inner);

  final File _inner;

  /// When `true`, [lastModifiedSync] throws as if the file were locked.
  bool failing = false;

  @override
  FileSystem get fileSystem => _inner.fileSystem;

  @override
  String get path => _inner.path;

  @override
  bool existsSync() => _inner.existsSync();

  @override
  DateTime lastModifiedSync() {
    if (failing) {
      throw FileSystemException('File is locked', _inner.path);
    }
    return _inner.lastModifiedSync();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

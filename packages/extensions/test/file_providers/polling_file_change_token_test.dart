import 'package:extensions/file_providers.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';

/// A file whose metadata reads can be made to fail on demand, standing in for
/// a network share that goes down or a file that becomes inaccessible.
class _FaultyFile implements File {
  _FaultyFile(this._delegate);

  final File _delegate;

  /// When true, [existsSync] and [lastModifiedSync] throw.
  bool failReads = false;

  @override
  bool existsSync() {
    if (failReads) {
      throw const FileSystemException('Simulated file system failure');
    }
    return _delegate.existsSync();
  }

  @override
  DateTime lastModifiedSync() {
    if (failReads) {
      throw const FileSystemException('Simulated file system failure');
    }
    return _delegate.lastModifiedSync();
  }

  @override
  String get path => _delegate.path;

  @override
  FileSystem get fileSystem => _delegate.fileSystem;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PollingFileChangeToken - Transient File System Errors', () {
    test('reports no change while the file cannot be read', () async {
      final fs = MemoryFileSystem();
      fs.file('/a.txt').writeAsStringSync('a');
      final file = _FaultyFile(fs.file('/a.txt'));

      final token = PollingFileChangeToken(
        file,
        pollingInterval: const Duration(milliseconds: 50),
      );

      file.failReads = true;

      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(token.hasChanged, isFalse);

      token.dispose();
    });

    test('detects a change made during an outage once it recovers', () async {
      final fs = MemoryFileSystem();
      fs.file('/a.txt').writeAsStringSync('a');
      final file = _FaultyFile(fs.file('/a.txt'));

      final token = PollingFileChangeToken(
        file,
        pollingInterval: const Duration(milliseconds: 50),
      );

      file.failReads = true;

      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(token.hasChanged, isFalse);

      file.failReads = false;
      fs.file('/a.txt').writeAsStringSync('modified');

      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(token.hasChanged, isTrue);

      token.dispose();
    });
  });
}

@TestOn('browser')
library;

import 'package:extensions/configuration.dart';
import 'package:extensions/file_providers.dart';
import 'package:extensions/file_system_globbing.dart' as fsg;
import 'package:file/memory.dart';
import 'package:test/test.dart';

/// Creates a posix-style in-memory filesystem seeded with [files].
MemoryFileSystem _seed(Map<String, String> files) {
  final fs = MemoryFileSystem();
  for (final entry in files.entries) {
    final file = fs.file(entry.key);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
  }
  return fs;
}

void main() {
  group('PhysicalFileProvider on web (memory-backed)', () {
    test('getFileInfo reads a seeded in-memory file', () {
      final fs = _seed({'/app/config.json': '{"a":1}'});
      final provider = PhysicalFileProvider('/app', fileSystem: fs);

      final info = provider.getFileInfo('config.json');

      expect(info.exists, isTrue);
      expect(info.name, 'config.json');
      expect((info as PhysicalFileInfo).readAsStringSync(), '{"a":1}');

      provider.dispose();
    });

    test('getFileInfo reports missing files as not found', () {
      final fs = MemoryFileSystem();
      final provider = PhysicalFileProvider('/app', fileSystem: fs);

      expect(provider.getFileInfo('missing.txt').exists, isFalse);

      provider.dispose();
    });

    test('getDirectoryContents enumerates a memory directory', () {
      final fs = _seed({
        '/app/a.txt': 'a',
        '/app/b.txt': 'b',
        '/app/sub/c.txt': 'c',
      });
      final provider = PhysicalFileProvider('/app', fileSystem: fs);

      final names =
          provider.getDirectoryContents('').map((f) => f.name).toList()..sort();

      expect(names, containsAll(<String>['a.txt', 'b.txt', 'sub']));

      provider.dispose();
    });
  });

  group('Polling change token on web', () {
    test('detects a change after a memory file is rewritten', () async {
      final fs = _seed({'/app/watched.txt': 'v1'});
      final provider = PhysicalFileProvider(
        '/app',
        fileSystem: fs,
        options: PhysicalFileProviderOptions(
          usePollingFileWatcher: true,
          pollingInterval: const Duration(milliseconds: 20),
        ),
      );

      final token = provider.watch('watched.txt');
      expect(token.hasChanged, isFalse);

      // Advance the recorded modification time so polling observes a change.
      await Future<void>.delayed(const Duration(milliseconds: 40));
      fs.file('/app/watched.txt').writeAsStringSync('v2');

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(token.hasChanged, isTrue);

      provider.dispose();
    });
  });

  group('JSON configuration on web (injected memory provider)', () {
    test('addJsonFile reads from a memory-backed provider', () {
      final fs = _seed({
        '/app/appsettings.json': '{"Greeting":"hello","Nested":{"Value":"42"}}',
      });
      final provider = PhysicalFileProvider('/app', fileSystem: fs);

      final config = (ConfigurationBuilder()
            ..setFileProvider(provider)
            ..addJsonFile('appsettings.json'))
          .build();

      expect(config['Greeting'], 'hello');
      expect(config['Nested:Value'], '42');
    });
  });

  group('Globbing on web (memory-backed)', () {
    test('Matcher.execute traverses an in-memory directory', () {
      final fs = _seed({
        '/root/a.txt': 'a',
        '/root/keep/b.txt': 'b',
        '/root/skip/c.log': 'c',
      });

      final matcher = fsg.Matcher()
        ..addInclude('*.txt')
        ..addInclude('**/*.txt')
        ..addExclude('skip/**');

      final result = matcher.execute(
        fsg.DirectoryInfoWrapper(fs.directory('/root')),
      );

      final paths = result.files.map((m) => m.path).toList()..sort();
      expect(paths, <String>['a.txt', 'keep/b.txt']);
    });
  });
}

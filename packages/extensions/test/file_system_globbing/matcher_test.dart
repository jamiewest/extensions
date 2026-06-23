import 'dart:io';

import 'package:extensions/file_system_globbing.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart' hide Matcher;

void main() {
  group('Matcher pattern collections', () {
    test('addInclude and addExclude expose unmodifiable views', () {
      final matcher = Matcher()
        ..addInclude('*.txt')
        ..addExclude('*.tmp');

      expect(matcher.includePatterns, equals(['*.txt']));
      expect(matcher.excludePatterns, equals(['*.tmp']));
      expect(() => matcher.includePatterns.add('x'), throwsUnsupportedError);
      expect(() => matcher.excludePatterns.add('x'), throwsUnsupportedError);
    });

    test('add*Patterns flatten nested pattern groups', () {
      final matcher = Matcher()
        ..addIncludePatterns([
          ['*.txt', '*.md'],
          ['*.json'],
        ])
        ..addExcludePatterns([
          ['*.tmp'],
        ]);

      expect(matcher.includePatterns, equals(['*.txt', '*.md', '*.json']));
      expect(matcher.excludePatterns, equals(['*.tmp']));
    });
  });

  group('matchFile (no file system access)', () {
    test('returns a match when the file matches an include pattern', () {
      final matcher = Matcher()..addInclude('**/*.txt');

      final result = matcher.matchFile('/root/docs/readme.txt', '/root');

      expect(result.hasFiles, isTrue);
      expect(result.files.single.path, equals(p.join('docs', 'readme.txt')));
    });

    test('returns no match when nothing includes the file', () {
      final matcher = Matcher()..addInclude('**/*.txt');

      final result = matcher.matchFile('/root/readme.md', '/root');

      expect(result.hasFiles, isFalse);
      expect(result.files, isEmpty);
    });

    test('exclude patterns suppress an otherwise-included file', () {
      final matcher = Matcher()
        ..addInclude('*.txt')
        ..addExclude('secret.txt');

      final included = matcher.matchFile('/root/a.txt', '/root');
      final excluded = matcher.matchFile('/root/secret.txt', '/root');

      expect(included.hasFiles, isTrue);
      expect(excluded.hasFiles, isFalse);
    });

    test('**/ only matches nested files, not the root (glob semantics)', () {
      final matcher = Matcher()..addInclude('**/*.txt');

      expect(matcher.matchFile('/root/a.txt', '/root').hasFiles, isFalse);
      expect(matcher.matchFile('/root/sub/a.txt', '/root').hasFiles, isTrue);
    });
  });

  group('matchFiles (no file system access)', () {
    test('filters a list by include and exclude patterns', () {
      final matcher = Matcher()
        ..addInclude('*.dart')
        ..addInclude('**/*.dart')
        ..addExclude('**/*.g.dart');

      final result = matcher.matchFiles([
        '/root/main.dart',
        '/root/lib/widget.dart',
        '/root/lib/widget.g.dart',
        '/root/readme.md',
      ], '/root');

      final paths = result.files.map((m) => m.path).toList();
      expect(paths, contains('main.dart'));
      expect(paths, contains(p.join('lib', 'widget.dart')));
      expect(paths, isNot(contains(p.join('lib', 'widget.g.dart'))));
      expect(paths, isNot(contains('readme.md')));
    });
  });

  group('execute against the real file system', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('matcher_test');
      File(p.join(tempDir.path, 'a.txt')).writeAsStringSync('a');
      File(p.join(tempDir.path, 'b.dart')).writeAsStringSync('b');
      final sub = Directory(p.join(tempDir.path, 'sub'))..createSync();
      File(p.join(sub.path, 'c.txt')).writeAsStringSync('c');
      File(p.join(sub.path, 'd.dart')).writeAsStringSync('d');
    });

    tearDown(() => tempDir.deleteSync(recursive: true));

    test('include pattern returns only matching files', () {
      final matcher = Matcher()
        ..addInclude('*.txt')
        ..addInclude('**/*.txt');

      final results = matcher.getResultsInFullPath(tempDir.path).toList();

      expect(results, hasLength(2));
      expect(results.every((path) => path.endsWith('.txt')), isTrue);
    });

    test('exclude pattern removes files from the results', () {
      final matcher = Matcher()
        ..addInclude('*.txt')
        ..addInclude('**/*.txt')
        ..addExclude('sub/**');

      final results = matcher.getResultsInFullPath(tempDir.path).toList();

      expect(results, hasLength(1));
      expect(results.single, endsWith('a.txt'));
    });

    test('a non-existent directory yields no results', () {
      final matcher = Matcher()..addInclude('**/*');

      final results =
          matcher.getResultsInFullPath(p.join(tempDir.path, 'missing'));

      expect(results, isEmpty);
    });
  });
}

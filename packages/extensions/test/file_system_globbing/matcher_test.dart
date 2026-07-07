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
      expect(result.files.single.path, equals('docs/readme.txt'));
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

    test('**/ matches files at the root and in subdirectories', () {
      final matcher = Matcher()..addInclude('**/*.txt');

      expect(matcher.matchFile('/root/a.txt', '/root').hasFiles, isTrue);
      expect(matcher.matchFile('/root/sub/a.txt', '/root').hasFiles, isTrue);
    });

    test('matching is case-insensitive by default', () {
      final matcher = Matcher()..addInclude('*.TXT');

      expect(matcher.matchFile('/root/a.txt', '/root').hasFiles, isTrue);
    });

    test('ordinal comparison makes matching case-sensitive', () {
      final matcher = Matcher(comparisonType: StringComparison.ordinal)
        ..addInclude('*.TXT');

      expect(matcher.matchFile('/root/a.txt', '/root').hasFiles, isFalse);
      expect(matcher.matchFile('/root/a.TXT', '/root').hasFiles, isTrue);
    });

    test('*.* is treated as *', () {
      final matcher = Matcher()..addInclude('*.*');

      expect(matcher.matchFile('/root/a.txt', '/root').hasFiles, isTrue);
    });

    test('a trailing slash matches the whole directory', () {
      final matcher = Matcher()..addInclude('lib/');

      expect(
        matcher.matchFile('/root/lib/src/a.dart', '/root').hasFiles,
        isTrue,
      );
      expect(
          matcher.matchFile('/root/other/a.dart', '/root').hasFiles, isFalse);
    });
  });

  group('stems', () {
    test('stem is relative to the first wildcard', () {
      final matcher = Matcher()..addInclude('src/project/**/*.cs');

      final result = matcher.matchFile(
        '/root/src/project/interfaces/file.cs',
        '/root',
      );

      expect(
          result.files.single.path, equals('src/project/interfaces/file.cs'));
      expect(result.files.single.stem, equals('interfaces/file.cs'));
    });

    test('literal pattern stem is the file name', () {
      final matcher = Matcher()..addInclude('sub/one.txt');

      final result = matcher.matchFile('/root/sub/one.txt', '/root');

      expect(result.files.single.stem, equals('one.txt'));
    });
  });

  group('preserveFilterOrder', () {
    test('a later include re-admits a previously excluded file', () {
      final matcher = Matcher(preserveFilterOrder: true)
        ..addInclude('**/*.txt')
        ..addExclude('sub/**')
        ..addInclude('sub/keep.txt');

      final result = matcher.matchFiles(
        ['a.txt', 'sub/drop.txt', 'sub/keep.txt'],
        '/root',
      );

      final paths = result.files.map((m) => m.path).toList();
      expect(paths, containsAll(['a.txt', 'sub/keep.txt']));
      expect(paths, isNot(contains('sub/drop.txt')));
    });

    test('default mode applies includes before excludes regardless of order',
        () {
      final matcher = Matcher()
        ..addInclude('**/*.txt')
        ..addExclude('sub/**')
        ..addInclude('sub/keep.txt');

      final result = matcher.matchFiles(
        ['a.txt', 'sub/keep.txt'],
        '/root',
      );

      final paths = result.files.map((m) => m.path).toList();
      expect(paths, equals(['a.txt']));
    });
  });

  group('matchFiles (no file system access)', () {
    test('filters a list by include and exclude patterns', () {
      final matcher = Matcher()
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
      expect(paths, contains('lib/widget.dart'));
      expect(paths, isNot(contains('lib/widget.g.dart')));
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
      final matcher = Matcher()..addInclude('**/*.txt');

      final results = matcher.getResultsInFullPath(tempDir.path).toList();

      expect(results, hasLength(2));
      expect(results.every((path) => path.endsWith('.txt')), isTrue);
    });

    test('exclude pattern removes files from the results', () {
      final matcher = Matcher()
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

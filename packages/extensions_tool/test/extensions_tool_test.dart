import 'dart:io';

import 'package:extensions_tool/extensions_tool.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('SourceAnnotationScanner', () {
    late Directory tempDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'source-annotation-scanner-test-',
      );
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('scans Dart files and finds @Source annotations', () async {
      await File(
        p.join(tempDirectory.path, 'annotated_named.dart'),
      ).writeAsString('''
@Source(
  name: 'NamedSource.cs',
  namespace: 'Example.Namespace',
  repository: 'example/repo',
  path: 'lib/src/system/source.cs',
)
final class NamedAnnotatedType {}
''');

      final positionalFile = File(
        p.join(tempDirectory.path, 'nested', 'annotated_positional.dart'),
      );
      await positionalFile.create(recursive: true);
      await positionalFile.writeAsString('''
@Source(
  'PositionalSource',
  'https://example.com/lib/src/system/source.cs',
)
final class PositionalAnnotatedType {}
''');

      await File(
        p.join(tempDirectory.path, 'plain.dart'),
      ).writeAsString('final class PlainType {}');

      final scanner = SourceAnnotationScanner();
      final report = await scanner.scanDirectory(tempDirectory.path);

      expect(report.scannedFileCount, 3);
      expect(report.annotatedFileCount, 2);
      expect(report.totalAnnotationCount, 2);
      expect(
        report.filesWithAnnotations.map((result) => p.basename(result.path)),
        containsAll(['annotated_named.dart', 'annotated_positional.dart']),
      );

      final namedMatch = report.files
          .firstWhere((file) => p.basename(file.path) == 'annotated_named.dart')
          .matches
          .single;
      expect(namedMatch.namedArgumentValues['name'], 'NamedSource.cs');
      expect(
        namedMatch.namedArgumentValues['path'],
        'lib/src/system/source.cs',
      );
      expect(namedMatch.sourceData, isNotNull);
      expect(namedMatch.sourceData!.namespace, 'Example.Namespace');

      final positionalMatch = report.files
          .firstWhere(
            (file) => p.basename(file.path) == 'annotated_positional.dart',
          )
          .matches
          .single;
      expect(positionalMatch.sourceData, isNull);
    });

    test('filters matches when source filename is provided', () async {
      await File(p.join(tempDirectory.path, 'source_match.dart')).writeAsString(
        '''
@Source(
  name: 'Match.cs',
  namespace: 'Example.Namespace',
  repository: 'example/repo',
  path: 'lib/src/system/source.cs',
)
final class MatchesSource {}
''',
      );

      await File(p.join(tempDirectory.path, 'other_file.dart')).writeAsString(
        '''
@Source(
  name: 'Other.cs',
  namespace: 'Example.Namespace',
  repository: 'example/repo',
  path: 'lib/src/system/other.cs',
)
final class DoesNotMatchSource {}
''',
      );

      final scanner = SourceAnnotationScanner();
      final report = await scanner.scanDirectory(
        tempDirectory.path,
        containsSourceFileName: 'source.cs',
      );

      expect(report.totalAnnotationCount, 1);
      expect(
        report.filesWithAnnotations.single.matches.single.argumentValues,
        contains('lib/src/system/source.cs'),
      );

      final extractedSource = report.extractedSources.single;
      expect(extractedSource.name, 'Match.cs');
      expect(extractedSource.namespace, 'Example.Namespace');
      expect(extractedSource.repository, 'example/repo');
      expect(extractedSource.path, 'lib/src/system/source.cs');
      expect(p.basename(extractedSource.filePath), 'source_match.dart');
    });
  });
}

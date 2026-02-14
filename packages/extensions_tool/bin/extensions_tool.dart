import 'package:extensions_tool/extensions_tool.dart';

Future<void> main(List<String> arguments) async {
  final directoryPath = arguments.isNotEmpty
      ? arguments.first
      : '/Users/jamie/Developer/github/extensions/packages/extensions/lib';
  final containsSourceFileName = arguments.length > 1 ? arguments[1] : null;

  final scanner = SourceAnnotationScanner();
  final report = await scanner.scanDirectory(
    directoryPath,
    containsSourceFileName: containsSourceFileName,
  );

  final extractedSources = report.extractedSources.toList(growable: false);

  for (final source in extractedSources) {
    print('${source.name} ${source.commit}');
  }
}

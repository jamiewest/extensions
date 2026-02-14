import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:path/path.dart' as p;

/// Scans Dart files for a custom annotation (defaults to `@Source`).
final class SourceAnnotationScanner {
  const SourceAnnotationScanner({
    this.annotationName = 'Source',
    this.fileExtensions = const {'.dart'},
  });

  final String annotationName;
  final Set<String> fileExtensions;

  /// Recursively scans [directoryPath] and returns matches for [annotationName].
  ///
  /// If [containsSourceFileName] is provided, only annotations that include
  /// that value in one of their string arguments are returned.
  Future<SourceAnnotationScanReport> scanDirectory(
    String directoryPath, {
    String? containsSourceFileName,
  }) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      throw FileSystemException(
        'Directory does not exist.',
        directory.absolute.path,
      );
    }

    final normalizedExtensions = fileExtensions
        .map((extension) => extension.toLowerCase())
        .toSet();

    final results = <SourceAnnotationFileResult>[];
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }

      final extension = p.extension(entity.path).toLowerCase();
      if (!normalizedExtensions.contains(extension)) {
        continue;
      }

      results.add(
        await _scanFile(
          file: entity,
          containsSourceFileName: containsSourceFileName,
        ),
      );
    }

    results.sort((a, b) => a.path.compareTo(b.path));

    return SourceAnnotationScanReport(
      directoryPath: directory.absolute.path,
      annotationName: annotationName,
      files: results,
      containsSourceFileName: containsSourceFileName,
    );
  }

  Future<SourceAnnotationFileResult> _scanFile({
    required File file,
    required String? containsSourceFileName,
  }) async {
    final content = await file.readAsString();
    final parsed = parseString(
      content: content,
      path: file.path,
      throwIfDiagnostics: false,
    );

    final lineInfo = parsed.lineInfo;
    final matches = <SourceAnnotationMatch>[];

    for (final declaration in parsed.unit.declarations) {
      for (final metadata in declaration.metadata) {
        final match = _toMatch(
          metadata,
          filePath: file.path,
          lineInfo: lineInfo,
          containsSourceFileName: containsSourceFileName,
        );
        if (match != null) {
          matches.add(match);
        }
      }
    }

    return SourceAnnotationFileResult(
      path: file.path,
      matches: matches,
      parseErrors: parsed.errors.map((error) => error.message).toList(),
    );
  }

  SourceAnnotationMatch? _toMatch(
    Annotation annotation, {
    required String filePath,
    required LineInfo lineInfo,
    required String? containsSourceFileName,
  }) {
    if (_identifierName(annotation.name) != annotationName) {
      return null;
    }

    final parsedArguments = _extractArguments(annotation.arguments);
    final argumentValues = parsedArguments.values;
    if (containsSourceFileName != null &&
        !argumentValues.any(
          (value) => value.toLowerCase().contains(
            containsSourceFileName.toLowerCase(),
          ),
        )) {
      return null;
    }

    final location = lineInfo.getLocation(annotation.offset);
    final sourceData = _toSourceData(
      parsedArguments.namedValues,
      filePath: filePath,
      line: location.lineNumber,
      column: location.columnNumber,
    );
    return SourceAnnotationMatch(
      line: location.lineNumber,
      column: location.columnNumber,
      argumentValues: argumentValues,
      namedArgumentValues: parsedArguments.namedValues,
      sourceData: sourceData,
    );
  }

  String _identifierName(Identifier identifier) {
    if (identifier is SimpleIdentifier) {
      return identifier.name;
    }

    if (identifier is PrefixedIdentifier) {
      return identifier.identifier.name;
    }

    return identifier.toSource();
  }

  _ParsedAnnotationArguments _extractArguments(ArgumentList? argumentList) {
    if (argumentList == null) {
      return const _ParsedAnnotationArguments(values: [], namedValues: {});
    }

    final values = <String>[];
    final namedValues = <String, String>{};
    for (final argument in argumentList.arguments) {
      if (argument is NamedExpression) {
        final value = _readStringValue(argument.expression);
        if (value != null) {
          values.add(value);
          namedValues[argument.name.label.name] = value;
        }
        continue;
      }

      final stringValue = _readStringValue(argument);
      if (stringValue != null) {
        values.add(stringValue);
      }
    }

    return _ParsedAnnotationArguments(values: values, namedValues: namedValues);
  }

  String? _readStringValue(Expression expression) {
    if (expression is SimpleStringLiteral) {
      return expression.value;
    }

    if (expression is StringInterpolation) {
      final buffer = StringBuffer();
      for (final element in expression.elements) {
        if (element is InterpolationString) {
          buffer.write(element.value);
        } else {
          return null;
        }
      }
      return buffer.toString();
    }

    return null;
  }

  SourceAnnotationData? _toSourceData(
    Map<String, String> namedValues, {
    required String filePath,
    required int line,
    required int column,
  }) {
    final name = namedValues['name'];
    final namespace = namedValues['namespace'];
    final repository = namedValues['repository'];
    final path = namedValues['path'];

    if (name == null ||
        namespace == null ||
        repository == null ||
        path == null) {
      return null;
    }

    return SourceAnnotationData(
      filePath: filePath,
      line: line,
      column: column,
      name: name,
      namespace: namespace,
      repository: repository,
      path: path,
      alias: namedValues['alias'],
      commit: namedValues['commit'],
      notes: namedValues['notes'],
    );
  }
}

final class SourceAnnotationScanReport {
  const SourceAnnotationScanReport({
    required this.directoryPath,
    required this.annotationName,
    required this.files,
    this.containsSourceFileName,
  });

  final String directoryPath;
  final String annotationName;
  final List<SourceAnnotationFileResult> files;
  final String? containsSourceFileName;

  int get scannedFileCount => files.length;

  int get annotatedFileCount => files.where((file) => file.hasMatches).length;

  int get totalAnnotationCount =>
      files.fold(0, (sum, file) => sum + file.matches.length);

  List<SourceAnnotationFileResult> get filesWithAnnotations =>
      files.where((file) => file.hasMatches).toList(growable: false);

  List<SourceAnnotationFileResult> get filesWithoutAnnotations =>
      files.where((file) => !file.hasMatches).toList(growable: false);

  Iterable<SourceAnnotationData> get extractedSources sync* {
    for (final file in files) {
      for (final match in file.matches) {
        final sourceData = match.sourceData;
        if (sourceData != null) {
          yield sourceData;
        }
      }
    }
  }
}

final class SourceAnnotationFileResult {
  const SourceAnnotationFileResult({
    required this.path,
    required this.matches,
    this.parseErrors = const [],
  });

  final String path;
  final List<SourceAnnotationMatch> matches;
  final List<String> parseErrors;

  bool get hasMatches => matches.isNotEmpty;

  @override
  String toString() =>
      'SourceAnnotationFileResult(path: $path, matches: ${matches.length})';
}

final class SourceAnnotationMatch {
  const SourceAnnotationMatch({
    required this.line,
    required this.column,
    required this.argumentValues,
    required this.namedArgumentValues,
    this.sourceData,
  });

  final int line;
  final int column;
  final List<String> argumentValues;
  final Map<String, String> namedArgumentValues;
  final SourceAnnotationData? sourceData;

  @override
  String toString() =>
      'SourceAnnotationMatch(line: $line, column: $column, values: $argumentValues)';
}

final class SourceAnnotationData {
  const SourceAnnotationData({
    required this.filePath,
    required this.line,
    required this.column,
    required this.name,
    required this.namespace,
    required this.repository,
    required this.path,
    this.alias,
    this.commit,
    this.notes,
  });

  final String filePath;
  final int line;
  final int column;

  final String name;
  final String namespace;
  final String repository;
  final String path;
  final String? alias;
  final String? commit;
  final String? notes;

  @override
  String toString() {
    return 'SourceAnnotationData('
        'name: $name, '
        'namespace: $namespace, '
        'repository: $repository, '
        'path: $path, '
        'filePath: $filePath, '
        'line: $line'
        ')';
  }
}

final class _ParsedAnnotationArguments {
  const _ParsedAnnotationArguments({
    required this.values,
    required this.namedValues,
  });

  final List<String> values;
  final Map<String, String> namedValues;
}

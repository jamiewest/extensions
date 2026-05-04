import 'dart:convert';
import 'dart:io';

import 'package:extensions/annotations.dart';

import '../../../chat_completion/chat_message.dart';
import '../../../chat_completion/chat_response.dart';
import '../../../chat_completion/chat_role.dart';
import '../../../../system/threading/cancellation_token.dart';
import '../../../usage_details.dart';
import '../../boolean_metric.dart';
import '../../evaluation_diagnostic.dart';
import '../../evaluation_diagnostic_severity.dart';
import '../../evaluation_metric.dart';
import '../../evaluation_metric_interpretation.dart';
import '../../evaluation_rating.dart';
import '../../evaluation_result.dart';
import '../../numeric_metric.dart';
import '../../string_metric.dart';
import '../chat_details.dart';
import '../chat_turn_details.dart';
import '../evaluation_result_store.dart';
import '../scenario_run_result.dart';

/// Stores [ScenarioRunResult]s as JSON files under [storageRootPath].
///
/// Layout:
/// ```
/// <storageRootPath>/results/<executionName>/<scenarioName>/<iterationName>.json
/// ```
@Source(
  name: 'DiskBasedResultStore.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Reporting.Storage',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.AI.Evaluation.Reporting.Storage/',
)
class DiskBasedResultStore implements EvaluationResultStore {
  /// Creates a [DiskBasedResultStore] rooted at [storageRootPath].
  DiskBasedResultStore(String storageRootPath)
      : _resultsRootPath =
            _join(Directory(storageRootPath).absolute.path, 'results');

  final String _resultsRootPath;

  @override
  Stream<ScenarioRunResult> readResults({
    String? executionName,
    String? scenarioName,
    String? iterationName,
    CancellationToken? cancellationToken,
  }) async* {
    _validateSegment(executionName, 'executionName');
    _validateSegment(scenarioName, 'scenarioName');
    _validateSegment(iterationName, 'iterationName');

    final resultsDir = Directory(_resultsRootPath);
    if (!resultsDir.existsSync()) return;

    for (final execDirPath
        in _enumerateExecutionDirs(resultsDir, executionName)) {
      for (final scenDirPath
          in _enumerateScenarioDirs(execDirPath, scenarioName)) {
        for (final filePath
            in _enumerateResultFiles(scenDirPath, iterationName)) {
          final json = jsonDecode(await File(filePath).readAsString())
              as Map<String, dynamic>;
          yield _resultFromJson(json);
        }
      }
    }
  }

  @override
  Future<void> writeResults(
    Iterable<ScenarioRunResult> results, {
    CancellationToken? cancellationToken,
  }) async {
    for (final result in results) {
      _validateSegment(result.executionName, 'executionName');
      _validateSegment(result.scenarioName, 'scenarioName');
      _validateSegment(result.iterationName, 'iterationName');

      final dir = Directory(
          _join(_resultsRootPath, result.executionName, result.scenarioName));
      dir.createSync(recursive: true);

      final file = File(_join(dir.path, '${result.iterationName}.json'));
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(_resultToJson(result)),
      );
    }
  }

  @override
  Future<void> deleteResults({
    String? executionName,
    String? scenarioName,
    String? iterationName,
    CancellationToken? cancellationToken,
  }) async {
    _validateSegment(executionName, 'executionName');
    _validateSegment(scenarioName, 'scenarioName');
    _validateSegment(iterationName, 'iterationName');

    final resultsDir = Directory(_resultsRootPath);
    if (!resultsDir.existsSync()) return;

    for (final execDirPath
        in _enumerateExecutionDirs(resultsDir, executionName)) {
      for (final scenDirPath
          in _enumerateScenarioDirs(execDirPath, scenarioName)) {
        for (final filePath
            in _enumerateResultFiles(scenDirPath, iterationName)) {
          await File(filePath).delete();
        }
      }
    }
  }

  @override
  Future<List<String>> getLatestExecutionNames(
    int count, {
    CancellationToken? cancellationToken,
  }) async {
    final resultsDir = Directory(_resultsRootPath);
    if (!resultsDir.existsSync()) return [];

    final dirs = resultsDir.listSync().whereType<Directory>().toList()
      ..sort((a, b) =>
          b.statSync().modified.compareTo(a.statSync().modified));

    return dirs.take(count).map((d) => _dirName(d.path)).toList();
  }

  // Filesystem enumeration helpers

  List<String> _enumerateExecutionDirs(
      Directory resultsDir, String? executionName) {
    if (executionName == null) {
      return resultsDir
          .listSync()
          .whereType<Directory>()
          .map((d) => d.path)
          .toList()
        ..sort((a, b) => Directory(b)
            .statSync()
            .modified
            .compareTo(Directory(a).statSync().modified));
    }
    final dir = _join(resultsDir.path, executionName);
    return Directory(dir).existsSync() ? [dir] : [];
  }

  List<String> _enumerateScenarioDirs(
      String execDirPath, String? scenarioName) {
    final execDir = Directory(execDirPath);
    if (!execDir.existsSync()) return [];
    if (scenarioName == null) {
      return execDir
          .listSync()
          .whereType<Directory>()
          .map((d) => d.path)
          .toList()
        ..sort();
    }
    final dir = _join(execDirPath, scenarioName);
    return Directory(dir).existsSync() ? [dir] : [];
  }

  List<String> _enumerateResultFiles(
      String scenDirPath, String? iterationName) {
    final scenDir = Directory(scenDirPath);
    if (!scenDir.existsSync()) return [];
    if (iterationName == null) {
      return scenDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .map((f) => f.path)
          .toList()
        ..sort();
    }
    final file = _join(scenDirPath, '$iterationName.json');
    return File(file).existsSync() ? [file] : [];
  }

  // Segment validation

  static void _validateSegment(String? segment, String paramName) {
    if (segment == null) return;
    if (segment.contains('/') ||
        segment.contains('\\') ||
        segment.contains('..')) {
      throw ArgumentError.value(
          segment, paramName, 'Path segment must not contain "/" or ".."');
    }
  }

  // JSON serialization

  static Map<String, dynamic> _resultToJson(ScenarioRunResult r) => {
        'scenarioName': r.scenarioName,
        'iterationName': r.iterationName,
        'executionName': r.executionName,
        'creationTime': r.creationTime.toIso8601String(),
        'messages': r.messages.map(_messageToJson).toList(),
        'modelResponse': _responseToJson(r.modelResponse),
        'evaluationResult': _evalResultToJson(r.evaluationResult),
        if (r.chatDetails != null)
          'chatDetails': _chatDetailsToJson(r.chatDetails!),
        if (r.tags != null) 'tags': r.tags,
        'formatVersion': r.formatVersion ?? 1,
      };

  static ScenarioRunResult _resultFromJson(Map<String, dynamic> j) =>
      ScenarioRunResult(
        scenarioName: j['scenarioName'] as String,
        iterationName: j['iterationName'] as String,
        executionName: j['executionName'] as String,
        creationTime: DateTime.parse(j['creationTime'] as String),
        messages: (j['messages'] as List)
            .map((m) => _messageFromJson(m as Map<String, dynamic>))
            .toList(),
        modelResponse:
            _responseFromJson(j['modelResponse'] as Map<String, dynamic>),
        evaluationResult:
            _evalResultFromJson(j['evaluationResult'] as Map<String, dynamic>),
        chatDetails: j['chatDetails'] != null
            ? _chatDetailsFromJson(j['chatDetails'] as Map<String, dynamic>)
            : null,
        tags: (j['tags'] as List?)?.cast<String>(),
        formatVersion: j['formatVersion'] as int?,
      );

  static Map<String, dynamic> _messageToJson(ChatMessage m) =>
      {'role': m.role.value, 'text': m.text};

  static ChatMessage _messageFromJson(Map<String, dynamic> j) =>
      ChatMessage.fromText(
          ChatRole(j['role'] as String), j['text'] as String? ?? '');

  static Map<String, dynamic> _responseToJson(ChatResponse r) => {
        'text': r.text,
        if (r.modelId != null) 'modelId': r.modelId,
        if (r.usage != null)
          'usage': {
            'inputTokenCount': r.usage!.inputTokenCount,
            'outputTokenCount': r.usage!.outputTokenCount,
            'totalTokenCount': r.usage!.totalTokenCount,
          },
      };

  static ChatResponse _responseFromJson(Map<String, dynamic> j) {
    final response = ChatResponse.fromMessage(
        ChatMessage.fromText(ChatRole.assistant, j['text'] as String? ?? ''));
    response.modelId = j['modelId'] as String?;
    return response;
  }

  static Map<String, dynamic> _evalResultToJson(EvaluationResult r) => {
        'metrics': r.metrics.map((k, v) => MapEntry(k, _metricToJson(v))),
      };

  static EvaluationResult _evalResultFromJson(Map<String, dynamic> j) {
    final map = (j['metrics'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, _metricFromJson(v as Map<String, dynamic>)));
    return EvaluationResult(metrics: map);
  }

  static Map<String, dynamic> _metricToJson(EvaluationMetric m) => {
        'name': m.name,
        'type': m is NumericMetric
            ? 'numeric'
            : m is BooleanMetric
                ? 'boolean'
                : 'string',
        if (m is NumericMetric) 'value': m.value,
        if (m is BooleanMetric) 'value': m.value,
        if (m is StringMetric) 'value': m.value,
        if (m.reason != null) 'reason': m.reason,
        if (m.interpretation != null)
          'interpretation': _interpretationToJson(m.interpretation!),
        if (m.diagnostics != null)
          'diagnostics': m.diagnostics!.map(_diagnosticToJson).toList(),
      };

  static EvaluationMetric _metricFromJson(Map<String, dynamic> j) {
    final name = j['name'] as String;
    final reason = j['reason'] as String?;
    EvaluationMetric metric;
    switch (j['type'] as String?) {
      case 'boolean':
        metric =
            BooleanMetric(name, value: j['value'] as bool?, reason: reason);
      case 'string':
        metric =
            StringMetric(name, value: j['value'] as String?, reason: reason);
      default:
        metric = NumericMetric(name,
            value: (j['value'] as num?)?.toDouble(), reason: reason);
    }
    if (j['interpretation'] != null) {
      metric.interpretation =
          _interpretationFromJson(j['interpretation'] as Map<String, dynamic>);
    }
    if (j['diagnostics'] != null) {
      metric.diagnostics = (j['diagnostics'] as List)
          .map((d) => _diagnosticFromJson(d as Map<String, dynamic>))
          .toList();
    }
    return metric;
  }

  static Map<String, dynamic> _interpretationToJson(
          EvaluationMetricInterpretation i) =>
      {
        'rating': i.rating.name,
        'failed': i.failed,
        if (i.reason != null) 'reason': i.reason,
      };

  static EvaluationMetricInterpretation _interpretationFromJson(
          Map<String, dynamic> j) =>
      EvaluationMetricInterpretation(
        rating: EvaluationRating.values.firstWhere(
            (r) => r.name == j['rating'] as String,
            orElse: () => EvaluationRating.unknown),
        failed: j['failed'] as bool? ?? false,
        reason: j['reason'] as String?,
      );

  static Map<String, dynamic> _diagnosticToJson(EvaluationDiagnostic d) =>
      {'severity': d.severity.name, 'message': d.message};

  static EvaluationDiagnostic _diagnosticFromJson(Map<String, dynamic> j) =>
      EvaluationDiagnostic(
        EvaluationDiagnosticSeverity.values.firstWhere(
            (s) => s.name == j['severity'] as String,
            orElse: () => EvaluationDiagnosticSeverity.informational),
        j['message'] as String,
      );

  static Map<String, dynamic> _chatDetailsToJson(ChatDetails d) => {
        'turnDetails': d.turnDetails.map(_turnToJson).toList(),
      };

  static ChatDetails _chatDetailsFromJson(Map<String, dynamic> j) =>
      ChatDetails(
        turnDetails: (j['turnDetails'] as List)
            .map((t) => _turnFromJson(t as Map<String, dynamic>))
            .toList(),
      );

  static Map<String, dynamic> _turnToJson(ChatTurnDetails t) => {
        'latencyMs': t.latency.inMilliseconds,
        if (t.model != null) 'model': t.model,
        if (t.modelProvider != null) 'modelProvider': t.modelProvider,
        if (t.usage != null)
          'usage': {
            'inputTokenCount': t.usage!.inputTokenCount,
            'outputTokenCount': t.usage!.outputTokenCount,
          },
        if (t.cacheKey != null) 'cacheKey': t.cacheKey,
        if (t.cacheHit != null) 'cacheHit': t.cacheHit,
      };

  static ChatTurnDetails _turnFromJson(Map<String, dynamic> j) {
    UsageDetails? usage;
    if (j['usage'] != null) {
      final u = j['usage'] as Map<String, dynamic>;
      usage = UsageDetails(
        inputTokenCount: u['inputTokenCount'] as int?,
        outputTokenCount: u['outputTokenCount'] as int?,
      );
    }
    return ChatTurnDetails(
      latency: Duration(milliseconds: j['latencyMs'] as int? ?? 0),
      model: j['model'] as String?,
      modelProvider: j['modelProvider'] as String?,
      usage: usage,
      cacheKey: j['cacheKey'] as String?,
      cacheHit: j['cacheHit'] as bool?,
    );
  }
}

// Internal path helper

String _join(String a, String b, [String? c]) {
  final sep = Platform.pathSeparator;
  return c != null ? '$a$sep$b$sep$c' : '$a$sep$b';
}

String _dirName(String path) {
  final segments = path.split(Platform.pathSeparator)
    ..removeWhere((s) => s.isEmpty);
  return segments.isEmpty ? path : segments.last;
}

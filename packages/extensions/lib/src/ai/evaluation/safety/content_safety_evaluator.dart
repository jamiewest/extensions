import 'dart:convert';
import 'dart:io';

import 'package:extensions/annotations.dart';

import '../../../system/threading/cancellation_token.dart';
import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_diagnostic.dart';
import '../evaluation_metric_extensions.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import '../numeric_metric.dart';
import 'content_safety_service_configuration.dart';

/// Base class for evaluators that call the Azure AI Foundry Evaluation service
/// to detect unsafe content.
///
/// Subclasses specify the annotation task name and the mapping from service
/// metric names to the [EvaluationMetric] names returned to callers.
@Source(
  name: 'ContentSafetyEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Safety',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Safety/',
)
abstract class ContentSafetyEvaluator implements Evaluator {
  /// Creates a [ContentSafetyEvaluator].
  ///
  /// [configuration] specifies the Azure project and credentials.
  /// [annotationTask] is the service task name (e.g. `"content harm"`).
  /// [metricNames] maps service metric keys to public metric names.
  ContentSafetyEvaluator({
    required this.configuration,
    required this.annotationTask,
    required Map<String, String> metricNames,
  }) : _metricNames = Map.unmodifiable(metricNames);

  /// Azure AI Foundry service configuration.
  final ContentSafetyServiceConfiguration configuration;

  /// The annotation task name sent to the service.
  final String annotationTask;

  final Map<String, String> _metricNames;

  @override
  List<String> get evaluationMetricNames =>
      _metricNames.values.toList(growable: false);

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async {
    final metrics = {
      for (final name in evaluationMetricNames) name: NumericMetric(name),
    };
    final result = EvaluationResult(
        metrics: {for (final m in metrics.values) m.name: m});

    try {
      final serviceResult = await _callService(
        messages: messages.toList(),
        modelResponse: modelResponse,
        additionalContext: additionalContext?.toList() ?? const [],
      );
      for (final entry in serviceResult.entries) {
        final publicName = _metricNames[entry.key];
        if (publicName != null && metrics.containsKey(publicName)) {
          metrics[publicName]!.value = entry.value;
          metrics[publicName]!.interpretation =
              metrics[publicName]!.interpretContentHarmScore();
        }
      }
    } catch (e) {
      for (final m in metrics.values) {
        m.addDiagnostic(EvaluationDiagnostic.error(e.toString()));
      }
    }

    return result;
  }

  /// Calls the Azure AI Foundry service and returns a map of metric keys to
  /// numeric scores.
  Future<Map<String, double>> _callService({
    required List<ChatMessage> messages,
    required ChatResponse modelResponse,
    required List<EvaluationContext> additionalContext,
  }) async {
    final uri = _buildUri();
    final payload = _buildPayload(messages, modelResponse, additionalContext);

    final client = HttpClient();
    client.connectionTimeout =
        Duration(seconds: configuration.timeoutInSeconds);
    try {
      final request = await client.postUrl(uri);
      request.headers
        ..set(HttpHeaders.contentTypeHeader, 'application/json')
        ..set('api-key', configuration.apiKey);
      request.write(jsonEncode(payload));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw StateError(
            'Azure AI Foundry service returned ${response.statusCode}: $body');
      }
      final json = jsonDecode(body) as Map<String, dynamic>;
      return _parseResponse(json);
    } finally {
      client.close();
    }
  }

  Uri _buildUri() {
    if (configuration.endpoint != null) {
      return configuration.endpoint!
          .replace(path: '${configuration.endpoint!.path}/evaluations/run');
    }
    return Uri.https(
      'management.azure.com',
      '/subscriptions/${configuration.subscriptionId}'
      '/resourceGroups/${configuration.resourceGroupName}'
      '/providers/Microsoft.MachineLearningServices'
      '/workspaces/${configuration.projectName}'
      '/evaluations/run',
    );
  }

  Map<String, dynamic> _buildPayload(
    List<ChatMessage> messages,
    ChatResponse modelResponse,
    List<EvaluationContext> additionalContext,
  ) {
    final conversation = [
      for (final m in messages)
        {'role': m.role.value, 'content': m.text},
      {'role': 'assistant', 'content': modelResponse.text},
    ];
    return {
      'annotation_task': annotationTask,
      'payload_format': 'conversation',
      'conversation': conversation,
    };
  }

  Map<String, double> _parseResponse(Map<String, dynamic> json) {
    final results = <String, double>{};
    final metrics = json['metrics'] as Map<String, dynamic>?;
    if (metrics != null) {
      for (final entry in metrics.entries) {
        final v = entry.value;
        if (v is num) results[entry.key] = v.toDouble();
      }
    }
    return results;
  }
}

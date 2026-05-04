import 'package:extensions/annotations.dart';

import '../../../system/threading/cancellation_token.dart';
import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../chat_configuration.dart';
import '../composite_evaluator.dart';
import '../evaluation_context.dart';
import '../evaluation_metric.dart';
import '../evaluation_metric_interpretation.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import 'chat_details.dart';
import 'evaluation_result_store.dart';
import 'scenario_run_result.dart';

/// Orchestrates the evaluation of a single iteration of a scenario.
///
/// Call [evaluate] once with the model response to score, then call [dispose]
/// (or use a try/finally) to persist the [ScenarioRunResult] to the
/// [EvaluationResultStore].
@Source(
  name: 'ScenarioRun.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Reporting',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Reporting/',
)
class ScenarioRun {
  /// Creates a [ScenarioRun].
  ScenarioRun(
    this.scenarioName,
    this.iterationName,
    this.executionName,
    Iterable<Evaluator> evaluators,
    EvaluationResultStore resultStore, {
    this.chatConfiguration,
    EvaluationMetricInterpretation? Function(EvaluationMetric)?
        evaluationMetricInterpreter,
    ChatDetails? chatDetails,
    Iterable<String>? tags,
  })  : _compositeEvaluator = CompositeEvaluator(evaluators.toList()),
        _resultStore = resultStore,
        _evaluationMetricInterpreter = evaluationMetricInterpreter,
        _chatDetails = chatDetails,
        _tags = tags?.toList();

  /// The name of the scenario.
  final String scenarioName;

  /// The name of the iteration within the scenario.
  final String iterationName;

  /// The execution name shared across all runs in one evaluation batch.
  final String executionName;

  /// Optional [ChatConfiguration] used by AI-based evaluators.
  final ChatConfiguration? chatConfiguration;

  final CompositeEvaluator _compositeEvaluator;
  final EvaluationResultStore _resultStore;
  final EvaluationMetricInterpretation? Function(EvaluationMetric)?
      _evaluationMetricInterpreter;
  final ChatDetails? _chatDetails;
  final List<String>? _tags;
  ScenarioRunResult? _result;

  /// Evaluates [modelResponse] against all configured evaluators and returns
  /// the aggregated [EvaluationResult].
  ///
  /// May only be called once per [ScenarioRun] instance. Call [dispose]
  /// afterwards to persist results.
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async {
    if (_result != null) {
      throw StateError(
        'ScenarioRun "$scenarioName/$iterationName/$executionName" has '
        'already been evaluated. Do not call evaluate() more than once.',
      );
    }

    final evaluationResult = await _compositeEvaluator.evaluate(
      messages,
      modelResponse,
      chatConfiguration: chatConfiguration,
      additionalContext: additionalContext,
      cancellationToken: cancellationToken,
    );

    if (_evaluationMetricInterpreter != null) {
      for (final metric in evaluationResult.metrics.values) {
        final override = _evaluationMetricInterpreter(metric);
        if (override != null) {
          metric.interpretation = override;
        }
      }
    }

    final details = _chatDetails;
    final chatDetails =
        (details != null && details.turnDetails.isNotEmpty) ? details : null;

    _result = ScenarioRunResult(
      scenarioName: scenarioName,
      iterationName: iterationName,
      executionName: executionName,
      creationTime: DateTime.now().toUtc(),
      messages: messages.toList(),
      modelResponse: modelResponse,
      evaluationResult: evaluationResult,
      chatDetails: chatDetails,
      tags: _tags,
    );

    return evaluationResult;
  }

  /// Writes the [ScenarioRunResult] to the [EvaluationResultStore].
  ///
  /// Should be called in a `finally` block after [evaluate].
  Future<void> dispose() async {
    if (_result != null) {
      await _resultStore.writeResults([_result!]);
    }
  }
}

import 'package:extensions/annotations.dart';

import '../../../system/threading/cancellation_token.dart';
import '../../chat_completion/chat_client.dart';
import '../chat_configuration.dart';
import '../evaluation_metric.dart';
import '../evaluation_metric_interpretation.dart';
import '../evaluator.dart';
import 'evaluation_response_cache_provider.dart';
import 'evaluation_result_store.dart';
import 'scenario_run.dart';

/// Bundles all configuration needed to create [ScenarioRun] instances for an
/// evaluation batch.
@Source(
  name: 'ReportingConfiguration.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Reporting',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Reporting/',
)
class ReportingConfiguration {
  /// Creates a [ReportingConfiguration].
  ///
  /// [evaluators] are the evaluators to run for each scenario.
  /// [resultStore] persists results.
  /// [chatConfiguration] is required for AI-based evaluators.
  /// [responseCacheProvider] enables response caching when non-null.
  /// [cachingKeys] are extra strings hashed into response cache keys.
  /// [executionName] uniquely identifies this batch; defaults to `"Default"`.
  /// [evaluationMetricInterpreter] overrides metric interpretations.
  /// [tags] are labels applied to every [ScenarioRun].
  ReportingConfiguration(
    Iterable<Evaluator> evaluators,
    this.resultStore, {
    this.chatConfiguration,
    this.responseCacheProvider,
    Iterable<String>? cachingKeys,
    String? executionName,
    this.evaluationMetricInterpreter,
    Iterable<String>? tags,
  })  : evaluators = List.unmodifiable(evaluators),
        cachingKeys = List.unmodifiable(cachingKeys ?? []),
        executionName = executionName ?? 'Default',
        tags = tags != null ? List.unmodifiable(tags) : null;

  /// The evaluators invoked for each scenario run.
  final List<Evaluator> evaluators;

  /// Where [ScenarioRunResult]s are persisted.
  final EvaluationResultStore resultStore;

  /// [ChatClient] configuration for AI-based evaluators.
  final ChatConfiguration? chatConfiguration;

  /// Optional response cache provider.
  final EvaluationResponseCacheProvider? responseCacheProvider;

  /// Additional strings mixed into response cache keys.
  final List<String> cachingKeys;

  /// Name for this evaluation batch execution.
  final String executionName;

  /// Optional function that overrides [EvaluationMetricInterpretation]s.
  final EvaluationMetricInterpretation? Function(EvaluationMetric)?
      evaluationMetricInterpreter;

  /// Labels applied to every [ScenarioRun] created from this configuration.
  final List<String>? tags;

  /// Creates a [ScenarioRun] for the given [scenarioName] and [iterationName].
  Future<ScenarioRun> createScenarioRun(
    String scenarioName,
    String iterationName, {
    CancellationToken? cancellationToken,
  }) async {
    return ScenarioRun(
      scenarioName,
      iterationName,
      executionName,
      evaluators,
      resultStore,
      chatConfiguration: chatConfiguration,
      evaluationMetricInterpreter: evaluationMetricInterpreter,
      tags: tags,
    );
  }
}

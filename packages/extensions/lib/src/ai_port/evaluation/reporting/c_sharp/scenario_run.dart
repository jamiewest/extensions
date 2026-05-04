import '../../../../../../../lib/func_typedefs.dart';
import '../../../abstractions/chat_completion/chat_client.dart';
import '../../../abstractions/chat_completion/chat_message.dart';
import '../../chat_configuration.dart';
import '../../composite_evaluator.dart';
import '../../evaluation_context.dart';
import '../../evaluation_metric_interpretation.dart';
import '../../evaluation_result.dart';
import '../../evaluator.dart';
import 'chat_details.dart';
import 'evaluation_result_store.dart';
import 'scenario_run_result.dart';

/// Represents a single execution of a particular iteration of a particular
/// scenario under evaluation.
///
/// Remarks: Each execution of an evaluation run is assigned a unique
/// [ExecutionName]. A single such evaluation run can contain evaluations for
/// multiple scenarios each with a unique [ScenarioName]. The execution of
/// each such scenario in turn can include multiple iterations each with a
/// unique [IterationName].
class ScenarioRun implements AsyncDisposable {
  ScenarioRun(
    String scenarioName,
    String iterationName,
    String executionName,
    Iterable<Evaluator> evaluators,
    EvaluationResultStore resultStore, {
    ChatConfiguration? chatConfiguration = null,
    Func<EvaluationMetric, EvaluationMetricInterpretation?>?
        evaluationMetricInterpreter =
        null,
    ChatDetails? chatDetails = null,
    Iterable<String>? tags = null,
  }) : scenarioName = scenarioName,
       iterationName = iterationName,
       executionName = executionName,
       chatConfiguration = chatConfiguration,
       _compositeEvaluator = compositeEvaluator(evaluators),
       _resultStore = resultStore,
       _evaluationMetricInterpreter = evaluationMetricInterpreter,
       _chatDetails = chatDetails,
       _tags = tags;

  /// Gets the name of the scenario that this [ScenarioRun] represents.
  ///
  /// Remarks: The [ScenarioName]s of different scenarios within a particular
  /// evaluation run must be unique. Logically, a scenario can be mapped to a
  /// single unit test within a suite of unit tests that are executed as part of
  /// an evaluation. In this case, the [ScenarioName] for each [ScenarioRun] in
  /// the suite can be set to the fully qualified name of the corresponding unit
  /// test.
  final String scenarioName;

  /// Gets the name of the iteration that this [ScenarioRun] represents.
  ///
  /// Remarks: The [IterationName]s of different iterations within a particular
  /// scenario execution must be unique. Logically, an iteration can be mapped
  /// to a single loop iteration within a particular unit test, or to a single
  /// data row within a data-driven test. [IterationName] could be set to any
  /// string that uniquely identifies the particular loop iteration / data row.
  /// For example, it could be set to an integer index that is incremented with
  /// each loop iteration.
  final String iterationName;

  /// Gets the name of the execution that this [ScenarioRun] represents.
  ///
  /// Remarks: [ExecutionName] can be set to any string that uniquely identifies
  /// a particular execution of a set scenarios and iterations that are part of
  /// an evaluation run. For example, [ExecutionName] could be set to the build
  /// number of the GitHub Actions workflow that runs the evaluation. Or it
  /// could be set to the version number of the product being evaluated. It
  /// could also be set to a timestamp (so long as all [ScenarioRun]s in a
  /// particular evaluation run share the same timestamp for their
  /// [ExecutionName]s). As new builds / workflows are kicked off over time,
  /// this would produce a series of executions each with a unique
  /// [ExecutionName]. The results for individual scenarios and iterations can
  /// then be compared across these different executions to track how the
  /// [EvaluationMetric]s for each scenario and iteration are trending over
  /// time. If the supplied [ExecutionName] is not unique, then the results for
  /// the scenarios and iterations from the previous execution with the same
  /// [ExecutionName] will be overwritten with the results from the new
  /// execution.
  final String executionName;

  /// Gets a [ChatConfiguration] that specifies the [ChatClient] that is used by
  /// AI-based [Evaluator]s that are invoked as part of the evaluation of this
  /// [ScenarioRun].
  final ChatConfiguration? chatConfiguration;

  final CompositeEvaluator _compositeEvaluator;

  final EvaluationResultStore _resultStore;

  final Func<EvaluationMetric, EvaluationMetricInterpretation?>?
  _evaluationMetricInterpreter;

  final ChatDetails? _chatDetails;

  final Iterable<String>? _tags;

  ScenarioRunResult? _result;

  /// Evaluates the supplied `modelResponse` and returns an [EvaluationResult]
  /// containing one or more [EvaluationMetric]s.
  ///
  /// Returns: An [EvaluationResult] containing one or more [EvaluationMetric]s.
  ///
  /// [messages] The conversation history including the request that produced
  /// the supplied `modelResponse`.
  ///
  /// [modelResponse] The response that is to be evaluated.
  ///
  /// [additionalContext] Additional contextual information (beyond that which
  /// is available in `messages`) that the [Evaluator]s included in this
  /// [ScenarioRun] may need to accurately evaluate the supplied
  /// `modelResponse`.
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the evaluation
  /// operation.
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async {
    if (_result != null) {
      throw invalidOperationException(
        'The ${nameof(ScenarioRun)} with ${nameof(scenarioName)}: ${scenarioName}, ${nameof(iterationName)}: ${iterationName} and ${nameof(executionName)}: ${executionName} has already been evaluated. Do not call ${nameof(EvaluateAsync)} more than once on a given ${nameof(ScenarioRun)}.',
      );
    }
    var evaluationResult = await _compositeEvaluator
        .evaluateAsync(
          messages,
          modelResponse,
          chatConfiguration,
          additionalContext,
          cancellationToken,
        )
        .configureAwait(false);
    if (_evaluationMetricInterpreter != null) {
      evaluationResult.interpret(_evaluationMetricInterpreter);
    }
    var chatDetails = _chatDetails != null && _chatDetails.turnDetails.any()
        ? _chatDetails
        : null;
    _result = scenarioRunResult(
      scenarioName,
      iterationName,
      executionName,
      creationTime: DateTime.utcNow,
      messages,
      modelResponse,
      evaluationResult,
      chatDetails,
      _tags,
    );
    return evaluationResult;
  }

  /// Disposes the [ScenarioRun] and writes the [ScenarioRunResult] to the
  /// configured [EvaluationResultStore].
  ///
  /// Returns: A [ValueTask] that represents the asynchronous operation.
  @override
  Future dispose() async {
    if (_result != null) {
      await _resultStore.writeResultsAsync([_result]).configureAwait(false);
    }
  }
}

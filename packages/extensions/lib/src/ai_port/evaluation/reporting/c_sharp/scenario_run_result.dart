import '../../../abstractions/chat_completion/chat_message.dart';
import '../../evaluation_result.dart';
import '../../evaluator.dart';
import 'chat_details.dart';
import 'scenario_run.dart';

/// Represents the results of a single execution of a particular iteration of
/// a particular scenario under evaluation. In other words,
/// [ScenarioRunResult] represents the results of evaluating a [ScenarioRun]
/// and includes the [EvaluationResult] that is produced when
/// [CancellationToken)] is invoked.
///
/// Remarks: Each execution of an evaluation run is assigned a unique
/// [ExecutionName]. A single such evaluation run can contain evaluations for
/// multiple scenarios each with a unique [ScenarioName]. The execution of
/// each such scenario in turn can include multiple iterations each with a
/// unique [IterationName].
///
/// [scenarioName] The [ScenarioName].
///
/// [iterationName] The [IterationName].
///
/// [executionName] The [ExecutionName].
///
/// [creationTime] The time at which this [ScenarioRunResult] was created.
///
/// [messages] The conversation history including the request that produced
/// the `modelResponse` being evaluated.
///
/// [modelResponse] The response being evaluated.
///
/// [evaluationResult] The [EvaluationResult] for the [ScenarioRun]
/// corresponding to the [ScenarioRunResult] being constructed.
///
/// [chatDetails] An optional [ChatDetails] object that contains details
/// related to all LLM chat conversation turns involved in the execution of
/// the the [ScenarioRun] corresponding to the [ScenarioRunResult] being
/// constructed. Can be `null` if none of the [Evaluator]s invoked during the
/// execution of the [ScenarioRun] use an LLM.
///
/// [tags] An optional set of text tags applicable to this
/// [ScenarioRunResult].
///
/// [formatVersion] The version of the format used to persist the current
/// [ScenarioRunResult].
class ScenarioRunResult {
  /// Represents the results of a single execution of a particular iteration of
  /// a particular scenario under evaluation. In other words,
  /// [ScenarioRunResult] represents the results of evaluating a [ScenarioRun]
  /// and includes the [EvaluationResult] that is produced when
  /// [CancellationToken)] is invoked.
  ///
  /// Remarks: Each execution of an evaluation run is assigned a unique
  /// [ExecutionName]. A single such evaluation run can contain evaluations for
  /// multiple scenarios each with a unique [ScenarioName]. The execution of
  /// each such scenario in turn can include multiple iterations each with a
  /// unique [IterationName].
  ///
  /// [scenarioName] The [ScenarioName].
  ///
  /// [iterationName] The [IterationName].
  ///
  /// [executionName] The [ExecutionName].
  ///
  /// [creationTime] The time at which this [ScenarioRunResult] was created.
  ///
  /// [messages] The conversation history including the request that produced
  /// the `modelResponse` being evaluated.
  ///
  /// [modelResponse] The response being evaluated.
  ///
  /// [evaluationResult] The [EvaluationResult] for the [ScenarioRun]
  /// corresponding to the [ScenarioRunResult] being constructed.
  ///
  /// [chatDetails] An optional [ChatDetails] object that contains details
  /// related to all LLM chat conversation turns involved in the execution of
  /// the the [ScenarioRun] corresponding to the [ScenarioRunResult] being
  /// constructed. Can be `null` if none of the [Evaluator]s invoked during the
  /// execution of the [ScenarioRun] use an LLM.
  ///
  /// [tags] An optional set of text tags applicable to this
  /// [ScenarioRunResult].
  ///
  /// [formatVersion] The version of the format used to persist the current
  /// [ScenarioRunResult].
  ScenarioRunResult(
    String scenarioName,
    String iterationName,
    String executionName,
    DateTime creationTime,
    ChatResponse modelResponse,
    EvaluationResult evaluationResult,
    ChatDetails? chatDetails, {
    List<ChatMessage>? messages = null,
    List<String>? tags = null,
    int? formatVersion = null,
  }) : scenarioName = scenarioName,
       iterationName = iterationName,
       executionName = executionName,
       creationTime = creationTime,
       modelResponse = modelResponse,
       evaluationResult = evaluationResult,
       chatDetails = chatDetails;

  /// Gets or sets the [ScenarioName].
  String scenarioName = scenarioName;

  /// Gets or sets the [IterationName].
  String iterationName = iterationName;

  /// Gets or sets the [ExecutionName].
  String executionName = executionName;

  /// Gets or sets the time at which this [ScenarioRunResult] was created.
  DateTime creationTime = creationTime;

  /// Gets or sets the conversation history including the request that produced
  /// the [ModelResponse] being evaluated in this [ScenarioRunResult].
  List<ChatMessage> messages = messages;

  /// Gets or sets the response being evaluated in this [ScenarioRunResult].
  ChatResponse modelResponse = modelResponse;

  /// Gets or sets the [EvaluationResult] for the [ScenarioRun] corresponding to
  /// this [ScenarioRunResult].
  ///
  /// Remarks: This is the same [EvaluationResult] that is returned when
  /// [CancellationToken)] is invoked.
  EvaluationResult evaluationResult = evaluationResult;

  /// Gets or sets an optional [ChatDetails] object that contains details
  /// related to all LLM chat conversation turns involved in the execution of
  /// the [ScenarioRun] corresponding to this [ScenarioRunResult].
  ///
  /// Remarks: Can be `null` if none of the [Evaluator]s invoked during the
  /// execution of the [ScenarioRun] use an LLM.
  ChatDetails? chatDetails = chatDetails;

  /// Gets or sets a set of text tags applicable to this [ScenarioRunResult].
  List<String>? tags = tags;

  /// Gets or sets the version of the format used to persist the current
  /// [ScenarioRunResult].
  int? formatVersion = formatVersion ?? Defaults.ReportingFormatVersion;
}

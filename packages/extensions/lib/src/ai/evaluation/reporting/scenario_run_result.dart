import 'package:extensions/annotations.dart';

import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../evaluation_result.dart';
import 'chat_details.dart';

/// The persisted result of a single [ScenarioRun] evaluation.
@Source(
  name: 'ScenarioRunResult.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Reporting',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Reporting/',
)
class ScenarioRunResult {
  /// Creates a [ScenarioRunResult].
  ScenarioRunResult({
    required this.scenarioName,
    required this.iterationName,
    required this.executionName,
    required this.creationTime,
    required this.messages,
    required this.modelResponse,
    required this.evaluationResult,
    this.chatDetails,
    this.tags,
    this.formatVersion = 1,
  });

  /// The scenario name.
  String scenarioName;

  /// The iteration name within the scenario.
  String iterationName;

  /// The execution name shared by all scenario runs in a single evaluation
  /// run.
  String executionName;

  /// Time at which this result was created.
  DateTime creationTime;

  /// The conversation history that produced [modelResponse].
  List<ChatMessage> messages;

  /// The model response being evaluated.
  ChatResponse modelResponse;

  /// The evaluation result for this scenario run.
  EvaluationResult evaluationResult;

  /// Details of LLM turns during this run; `null` if no AI evaluators ran.
  ChatDetails? chatDetails;

  /// Optional tags for this result.
  List<String>? tags;

  /// Format version for persistence compatibility.
  int? formatVersion;
}

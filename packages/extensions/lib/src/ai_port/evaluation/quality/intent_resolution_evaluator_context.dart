import '../../abstractions/functions/ai_function_declaration.dart';
import '../../abstractions/tools/ai_tool.dart';
import '../../open_telemetry_consts.dart';
import '../evaluation_context.dart';
import 'intent_resolution_evaluator.dart';

/// Contextual information that the [IntentResolutionEvaluator] uses to
/// evaluate an AI system's effectiveness at identifying and resolving user
/// intent.
///
/// Remarks: [IntentResolutionEvaluator] evaluates an AI system's
/// effectiveness at identifying and resolving user intent based on the
/// supplied conversation history and the tool definitions supplied via
/// [ToolDefinitions]. Note that at the moment, [IntentResolutionEvaluator]
/// only supports evaluating calls to tools that are defined as
/// [AIFunctionDeclaration]s. Any other [AITool] definitions that are supplied
/// via [ToolDefinitions] will be ignored.
class IntentResolutionEvaluatorContext extends EvaluationContext {
  /// Initializes a new instance of the [IntentResolutionEvaluatorContext]
  /// class.
  ///
  /// [toolDefinitions] The set of tool definitions (see [Tools]) that were used
  /// when generating the model response that is being evaluated. Note that at
  /// the moment, [IntentResolutionEvaluator] only supports evaluating calls to
  /// tools that are defined as [AIFunctionDeclaration]s. Any other [AITool]
  /// definitions will be ignored.
  IntentResolutionEvaluatorContext({List<ATool>? toolDefinitions = null}) : toolDefinitions = [.. toolDefinitions];

  /// Gets set of tool definitions (see [Tools]) that were used when generating
  /// the model response that is being evaluated.
  ///
  /// Remarks: [IntentResolutionEvaluator] evaluates an AI system's
  /// effectiveness at identifying and resolving user intent based on the
  /// supplied conversation history and the tool definitions supplied via
  /// [ToolDefinitions]. Note that at the moment, [IntentResolutionEvaluator]
  /// only supports evaluating calls to tools that are defined as
  /// [AIFunctionDeclaration]s. Any other [AITool] definitions that are supplied
  /// via [ToolDefinitions] will be ignored.
  final List<ATool> toolDefinitions;

  /// Gets the unique [Name] that is used for
  /// [IntentResolutionEvaluatorContext].
  static String get toolDefinitionsContextName {
    return "Tool definitions(Intent Resolution)";
  }
}

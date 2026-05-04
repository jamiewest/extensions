import '../../abstractions/functions/ai_function_declaration.dart';
import '../../abstractions/tools/ai_tool.dart';
import '../../open_telemetry_consts.dart';
import '../evaluation_context.dart';
import 'task_adherence_evaluator.dart';

/// Contextual information that the [TaskAdherenceEvaluator] uses to evaluate
/// an AI system's effectiveness at adhering to the task assigned to it.
///
/// Remarks: [TaskAdherenceEvaluator] measures how accurately an AI system
/// adheres to the task assigned to it by examining the alignment of the
/// supplied response with instructions and definitions present in the
/// conversation history, the accuracy and clarity of the response, and the
/// proper use of tool definitions supplied via [ToolDefinitions]. Note that
/// at the moment, [TaskAdherenceEvaluator] only supports evaluating calls to
/// tools that are defined as [AIFunctionDeclaration]s. Any other [AITool]
/// definitions that are supplied via [ToolDefinitions] will be ignored.
class TaskAdherenceEvaluatorContext extends EvaluationContext {
  /// Initializes a new instance of the [TaskAdherenceEvaluatorContext] class.
  ///
  /// [toolDefinitions] The set of tool definitions (see [Tools]) that were used
  /// when generating the model response that is being evaluated. Note that at
  /// the moment, [TaskAdherenceEvaluator] only supports evaluating calls to
  /// tools that are defined as [AIFunctionDeclaration]s. Any other [AITool]
  /// definitions will be ignored.
  TaskAdherenceEvaluatorContext({List<ATool>? toolDefinitions = null}) : toolDefinitions = [.. toolDefinitions];

  /// Gets set of tool definitions (see [Tools]) that were used when generating
  /// the model response that is being evaluated.
  ///
  /// Remarks: [TaskAdherenceEvaluator] measures how accurately an AI system
  /// adheres to the task assigned to it by examining the alignment of the
  /// supplied response with instructions and definitions present in the
  /// conversation history, the accuracy and clarity of the response, and the
  /// proper use of tool definitions supplied via [ToolDefinitions]. Note that
  /// at the moment, [TaskAdherenceEvaluator] only supports evaluating calls to
  /// tools that are defined as [AIFunctionDeclaration]s. Any other [AITool]
  /// definitions that are supplied via [ToolDefinitions] will be ignored.
  final List<ATool> toolDefinitions;

  /// Gets the unique [Name] that is used for [TaskAdherenceEvaluatorContext].
  static String get toolDefinitionsContextName {
    return "Tool definitions(Task Adherence)";
  }
}

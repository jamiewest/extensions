import '../../abstractions/contents/function_call_content.dart';
import '../../abstractions/functions/ai_function_declaration.dart';
import '../../abstractions/tools/ai_tool.dart';
import '../../open_telemetry_consts.dart';
import '../evaluation_context.dart';
import 'tool_call_accuracy_evaluator.dart';

/// Contextual information that the [ToolCallAccuracyEvaluator] uses to
/// evaluate an AI system's effectiveness at using the tools supplied to it.
///
/// Remarks: [ToolCallAccuracyEvaluator] measures how accurately an AI system
/// uses tools by examining tool calls (i.e., [FunctionCallContent]s) present
/// in the supplied response to assess the relevance of these tool calls to
/// the conversation, the parameter correctness for these tool calls with
/// regard to the tool definitions supplied via [ToolDefinitions], and the
/// accuracy of the parameter value extraction from the supplied conversation
/// history. Note that at the moment, [ToolCallAccuracyEvaluator] only
/// supports evaluating calls to tools that are defined as
/// [AIFunctionDeclaration]s. Any other [AITool] definitions that are supplied
/// via [ToolDefinitions] will be ignored.
class ToolCallAccuracyEvaluatorContext extends EvaluationContext {
  /// Initializes a new instance of the [ToolCallAccuracyEvaluatorContext]
  /// class.
  ///
  /// [toolDefinitions] The set of tool definitions (see [Tools]) that were used
  /// when generating the model response that is being evaluated. Note that at
  /// the moment, [ToolCallAccuracyEvaluator] only supports evaluating calls to
  /// tools that are defined as [AIFunctionDeclaration]s. Any other [AITool]
  /// definitions will be ignored.
  ToolCallAccuracyEvaluatorContext({List<ATool>? toolDefinitions = null}) : toolDefinitions = [.. toolDefinitions];

  /// Gets set of tool definitions (see [Tools]) that were used when generating
  /// the model response that is being evaluated.
  ///
  /// Remarks: [ToolCallAccuracyEvaluator] measures how accurately an AI system
  /// uses tools by examining tool calls (i.e., [FunctionCallContent]s) present
  /// in the supplied response to assess the relevance of these tool calls to
  /// the conversation, the parameter correctness for these tool calls with
  /// regard to the tool definitions supplied via [ToolDefinitions], and the
  /// accuracy of the parameter value extraction from the supplied conversation
  /// history. Note that at the moment, [ToolCallAccuracyEvaluator] only
  /// supports evaluating calls to tools that are defined as
  /// [AIFunctionDeclaration]s. Any other [AITool] definitions that are supplied
  /// via [ToolDefinitions] will be ignored.
  final List<ATool> toolDefinitions;

  /// Gets the unique [Name] that is used for
  /// [ToolCallAccuracyEvaluatorContext].
  static String get toolDefinitionsContextName {
    return "Tool definitions(Tool Call Accuracy)";
  }
}

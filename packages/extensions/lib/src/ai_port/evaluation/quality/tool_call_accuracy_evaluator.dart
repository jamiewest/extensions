import '../../abstractions/chat_completion/chat_message.dart';
import '../../abstractions/chat_completion/chat_options.dart';
import '../../abstractions/chat_completion/chat_role.dart';
import '../../abstractions/contents/function_call_content.dart';
import '../../abstractions/functions/ai_function_declaration.dart';
import '../../abstractions/tools/ai_tool.dart';
import '../../open_telemetry_consts.dart';
import '../boolean_metric.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_diagnostic.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import '../utilities/timing_helper.dart';
import 'tool_call_accuracy_evaluator_context.dart';

/// An [Evaluator] that evaluates an AI system's effectiveness at using the
/// tools supplied to it.
///
/// Remarks: [ToolCallAccuracyEvaluator] measures how accurately an AI system
/// uses tools by examining tool calls (i.e., [FunctionCallContent]s) present
/// in the supplied response to assess the relevance of these tool calls to
/// the conversation, the parameter correctness for these tool calls with
/// regard to the tool definitions supplied via [ToolDefinitions], and the
/// accuracy of the parameter value extraction from the supplied conversation.
/// Note that at the moment, [ToolCallAccuracyEvaluator] only supports
/// evaluating calls to tools that are defined as [AIFunctionDeclaration]s.
/// Any other [AITool] definitions that are supplied via [ToolDefinitions]
/// will be ignored. [ToolCallAccuracyEvaluator] returns a [BooleanMetric]
/// that contains a score for 'Tool Call Accuracy'. The score is `false` if
/// the tool call is irrelevant or contains information not present in the
/// conversation and `true` if the tool call is relevant with properly
/// extracted parameters from the conversation. Note:
/// [ToolCallAccuracyEvaluator] is an AI-based evaluator that uses an AI model
/// to perform its evaluation. While the prompt that this evaluator uses to
/// perform its evaluation is designed to be model-agnostic, the performance
/// of this prompt (and the resulting evaluation) can vary depending on the
/// model used, and can be especially poor when a smaller / local model is
/// used. The prompt that [ToolCallAccuracyEvaluator] uses has been tested
/// against (and tuned to work well with) the following models. So, using this
/// evaluator with a model from the following list is likely to produce the
/// best results. (The model to be used can be configured via [ChatClient].)
/// GPT-4o
class ToolCallAccuracyEvaluator implements Evaluator {
  ToolCallAccuracyEvaluator();

  final ReadOnlyCollection<String> evaluationMetricNames = [ToolCallAccuracyMetricName];

  static final ChatOptions _chatOptions;

  /// Gets the [Name] of the [BooleanMetric] returned by
  /// [ToolCallAccuracyEvaluator].
  static String get toolCallAccuracyMetricName {
    return "Tool Call Accuracy";
  }

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse,
    {ChatConfiguration? chatConfiguration, Iterable<EvaluationContext>? additionalContext, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(modelResponse);
    _ = Throw.ifNull(chatConfiguration);
    var metric = booleanMetric(toolCallAccuracyMetricName);
    var result = evaluationResult(metric);
    metric.markAsBuiltIn();
    if (!messages.any()) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error(
                    "The conversation history supplied for evaluation did not include any messages."));
      return result;
    }
    var toolCalls = modelResponse.messages.selectMany((m) => m.contents).ofType<FunctionCallContent>();
    if (!toolCalls.any()) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error('The ${nameof(modelResponse)} supplied for evaluation did not contain any tool calls (i.e., ${nameof(FunctionCallContent)}s).'));
      return result;
    }
    if (additionalContext?.ofType<ToolCallAccuracyEvaluatorContext>().firstOrDefault() is! ToolCallAccuracyEvaluatorContext context) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error(
                    'A value of type ${nameof(ToolCallAccuracyEvaluatorContext)} was not found in the ${nameof(additionalContext)} collection.'));
      return result;
    }
    if (context.toolDefinitions.count is 0) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error(
                    'Supplied ${nameof(ToolCallAccuracyEvaluatorContext)} did not contain any ${nameof(ToolCallAccuracyEvaluatorContext.toolDefinitions)}.'));
      return result;
    }
    var toolDefinitionNames = HashSet<String>(context.toolDefinitions.select((td) => td.name));
    if (toolCalls.any((t) => !toolDefinitionNames.contains(t.name))) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error(
                    'The ${nameof(modelResponse)} supplied for evaluation contained calls to tools that were not included in the supplied ${nameof(ToolCallAccuracyEvaluatorContext)}.'));
      return result;
    }
    var evaluationInstructions = getEvaluationInstructions(messages, modelResponse, context);
    (ChatResponse evaluationResponse, TimeSpan evaluationDuration) =
            await TimingHelper.executeWithTimingAsync(() =>
                chatConfiguration.chatClient.getResponseAsync(
                    evaluationInstructions,
                    _chatOptions,
                    cancellationToken)).configureAwait(false);
    _ = metric.tryParseEvaluationResponseWithTags(evaluationResponse, evaluationDuration);
    metric.addOrUpdateContext(context);
    metric.interpretation = metric.interpretScore();
    return result;
  }

  static List<ChatMessage> getEvaluationInstructions(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse,
    ToolCallAccuracyEvaluatorContext context,
  ) {
    var SystemPrompt = """
            # Instruction
            ## Goal
            ### You are an expert in evaluating the accuracy of a tool call considering relevance and potential usefulness including syntactic and semantic correctness of a proposed tool call from an intelligent system based on provided definition and data. Your goal will involve answering the questions below using the information provided.
            - **Definition**: You are given a definition of the communication trait that is being evaluated to help guide your Score.
            - **Data**: Your input data include CONVERSATION , TOOL CALL and TOOL DEFINITION.
            - **Tasks**: To complete your evaluation you will be asked to evaluate the Data in different ways.
            """;
    var evaluationInstructions = [chatMessage(ChatRole.system, SystemPrompt)];
    var renderedConversation = messages.renderText();
    var renderedToolCallsAndResults = modelResponse.renderToolCallsAndResultsAsJson();
    var renderedToolDefinitions = context.toolDefinitions.renderAsJson();
    var evaluationPrompt = $''"
            # Definition
            **Tool Call Accuracy** refers to the relevance and potential usefulness of a TOOL CALL in the context of an ongoing CONVERSATION and EXTRACTION of RIGHT PARAMETER VALUES from the CONVERSATION.it assesses how likely the TOOL CALL is to contribute meaningfully to the CONVERSATION and help address the user's needs. Focus on evaluating the potential value of the TOOL CALL within the specific context of the given CONVERSATION, without making assumptions beyond the provided information.
              Consider the following factors in your evaluation:

              1. Relevance: How well does the proposed tool call align with the current topic and flow of the conversation?
              2. Parameter Appropriateness: Do the parameters used in the TOOL CALL match the TOOL DEFINITION and are the parameters relevant to the latest user's query?
              3. Parameter Value Correctness: Are the parameters values used in the TOOL CALL present or inferred by CONVERSATION and relevant to the latest user's query?
              4. Potential Value: Is the information this tool call might provide likely to be useful in advancing the conversation or addressing the user expressed or implied needs?
              5. Context Appropriateness: Does the tool call make sense at this point in the conversation, given what has been discussed so far?


            # Ratings
            ## [Tool Call Accuracy: 0] (Irrelevant)
            **Definition:**
             1. The TOOL CALL is! relevant and will not help resolve the user's need.
             2. TOOL CALL include parameters values that are not present or inferred from CONVERSATION.
             3. TOOL CALL has parameters that is! present in TOOL DEFINITION.

            ## [Tool Call Accuracy: 1] (Relevant)
            **Definition:**
             1. The TOOL CALL is directly relevant and very likely to help resolve the user's need.
             2. TOOL CALL include parameters values that are present or inferred from CONVERSATION.
             3. TOOL CALL has parameters that is present in TOOL DEFINITION.

            # Data
            CONVERSATION : {{renderedConversation}}
            TOOL CALL: {{renderedToolCallsAndResults}}
            TOOL DEFINITION: {{renderedToolDefinitions}}


            # Tasks
            ## Please provide your assessment Score for the previous CONVERSATION , TOOL CALL and TOOL DEFINITION based on the Definitions above. Your output should include the following information:
            - **ThoughtChain**: To improve the reasoning process, think step by step and include a step-by-step explanation of your thought process as you analyze the data based on the definitions. Keep it brief and start your ThoughtChain with "Let's think step by step:".
            - **Explanation**: a very short explanation of why you think the input Data should get that Score.
            - **Score**: based on your previous analysis, provide your Score. The Score you give MUST be a integer score (
              i.e.,
              "0",
              "1",
            ) based on the levels of the definitions.


            ## Please provide your answers between the tags: <S0>your chain of thoughts</S0>, <S1>your explanation</S1>, <S2>your Score</S2>.
            # Output
            """;
    evaluationInstructions.add(chatMessage(ChatRole.user, evaluationPrompt));
    return evaluationInstructions;
  }
}

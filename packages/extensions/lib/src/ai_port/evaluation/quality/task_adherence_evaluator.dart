import '../../abstractions/chat_completion/chat_message.dart';
import '../../abstractions/chat_completion/chat_options.dart';
import '../../abstractions/chat_completion/chat_role.dart';
import '../../abstractions/contents/function_call_content.dart';
import '../../abstractions/functions/ai_function_declaration.dart';
import '../../abstractions/tools/ai_tool.dart';
import '../../open_telemetry_consts.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_diagnostic.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import '../numeric_metric.dart';
import '../utilities/timing_helper.dart';
import 'task_adherence_evaluator_context.dart';

/// An [Evaluator] that evaluates an AI system's effectiveness at adhering to
/// the task assigned to it.
///
/// Remarks: [TaskAdherenceEvaluator] measures how accurately an AI system
/// adheres to the task assigned to it by examining the alignment of the
/// supplied response with instructions and definitions present in the
/// conversation history, the accuracy and clarity of the response, and the
/// proper use of tool definitions supplied via [ToolDefinitions]. Note that
/// at the moment, [TaskAdherenceEvaluator] only supports evaluating calls to
/// tools that are defined as [AIFunctionDeclaration]s. Any other [AITool]
/// definitions that are supplied via [ToolDefinitions] will be ignored.
/// [TaskAdherenceEvaluator] returns a [NumericMetric] that contains a score
/// for 'Task Adherence'. The score is a number between 1 and 5, with 1
/// indicating a poor score, and 5 indicating an excellent score. Note:
/// [TaskAdherenceEvaluator] is an AI-based evaluator that uses an AI model to
/// perform its evaluation. While the prompt that this evaluator uses to
/// perform its evaluation is designed to be model-agnostic, the performance
/// of this prompt (and the resulting evaluation) can vary depending on the
/// model used, and can be especially poor when a smaller / local model is
/// used. The prompt that [TaskAdherenceEvaluator] uses has been tested
/// against (and tuned to work well with) the following models. So, using this
/// evaluator with a model from the following list is likely to produce the
/// best results. (The model to be used can be configured via [ChatClient].)
/// GPT-4o
class TaskAdherenceEvaluator implements Evaluator {
  TaskAdherenceEvaluator();

  final ReadOnlyCollection<String> evaluationMetricNames = [TaskAdherenceMetricName];

  static final ChatOptions _chatOptions;

  /// Gets the [Name] of the [NumericMetric] returned by
  /// [TaskAdherenceEvaluator].
  static String get taskAdherenceMetricName {
    return "Task Adherence";
  }

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse,
    {ChatConfiguration? chatConfiguration, Iterable<EvaluationContext>? additionalContext, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(modelResponse);
    _ = Throw.ifNull(chatConfiguration);
    var metric = numericMetric(taskAdherenceMetricName);
    var result = evaluationResult(metric);
    metric.markAsBuiltIn();
    if (!messages.any()) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error(
                    "The conversation history supplied for evaluation did not include any messages."));
      return result;
    }
    if (!modelResponse.messages.any()) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error(
                    'The ${nameof(modelResponse)} supplied for evaluation did not include any messages.'));
      return result;
    }
    var context = additionalContext?.ofType<TaskAdherenceEvaluatorContext>().firstOrDefault();
    if (context != null && context.toolDefinitions.count is 0) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error(
                    'Supplied ${nameof(TaskAdherenceEvaluatorContext)} did not contain any ${nameof(TaskAdherenceEvaluatorContext.toolDefinitions)}.'));
      return result;
    }
    var toolDefinitionNames = HashSet<String>(context?.toolDefinitions.select((td) => td.name) ?? []);
    var toolCalls = modelResponse.messages.selectMany((m) => m.contents).ofType<FunctionCallContent>();
    if (toolCalls.any((t) => !toolDefinitionNames.contains(t.name))) {
      if (context == null) {
        metric.addDiagnostics(
                    EvaluationDiagnostic.error(
                        'The ${nameof(modelResponse)} supplied for evaluation contained calls to tools that were not supplied via ${nameof(TaskAdherenceEvaluatorContext)}.'));
      } else {
        metric.addDiagnostics(
                    EvaluationDiagnostic.error(
                        'The ${nameof(modelResponse)} supplied for evaluation contained calls to tools that were not included in the supplied ${nameof(TaskAdherenceEvaluatorContext)}.'));
      }
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
    if (context != null) {
      metric.addOrUpdateContext(context);
    }
    metric.interpretation = metric.interpretScore();
    return result;
  }

  static List<ChatMessage> getEvaluationInstructions(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse,
    TaskAdherenceEvaluatorContext? context,
  ) {
    var renderedConversation = messages.renderAsJson();
    var renderedModelResponse = modelResponse.renderAsJson();
    var renderedToolDefinitions = context?.toolDefinitions.renderAsJson();
    var systemPrompt = $''"
            # Instruction
            ## Context
            ### You are an expert in evaluating the quality of an answer from an intelligent system based on provided definitions and data. Your goal will involve answering the questions below using the information provided.
            - **Definition**: Based on the provided query, response, and tool definitions, evaluate the agent's adherence to the assigned task.
            - **Data**: Your input data includes query, response, and tool definitions.
            - **Questions**: To complete your evaluation you will be asked to evaluate the Data in different ways.

            # Definition

            **Level 1: Fully Inadherent**

            **Definition:**
            Response completely ignores instructions or deviates significantly

            **Example:**
              **Query:** What is a recommended weekend itinerary in Paris?
              **Response:** Paris is a lovely city with a rich history.

            Explanation: This response completely misses the task by not providing any itinerary details. It offers a generic statement about Paris rather than a structured travel plan.


            **Level 2: Barely Adherent**

            **Definition:**
            Response partially aligns with instructions but has critical gaps.

            **Example:**
              **Query:** What is a recommended weekend itinerary in Paris?
              **Response:** Spend your weekend visiting famous places in Paris.

            Explanation: While the response hints at visiting well-known sites, it is extremely vague and lacks specific details, such as which sites to visit or any order of activities, leaving major gaps in the instructions.


            **Level 3: Moderately Adherent**

            **Definition:**
            Response meets the core requirements but lacks precision or clarity.

            **Example:**
              **Query:** What is a recommended weekend itinerary in Paris?
              **Response:** Visit the Eiffel Tower and the Louvre on Saturday, and stroll through Montmartre on Sunday.

            Explanation: This answer meets the basic requirement by naming a few key attractions and assigning them to specific days. However, it lacks additional context, such as timings, additional activities, or details to make the itinerary practical and clear.


            **Level 4: Mostly Adherent**

            **Definition:**
            Response is clear, accurate, and aligns with instructions with minor issues.

            **Example:**
              **Query:** What is a recommended weekend itinerary in Paris?
              **Response:** For a weekend in Paris, start Saturday with a morning visit to the Eiffel Tower, then head to the Louvre in the early afternoon. In the evening, enjoy a leisurely walk along the Seine. On Sunday, begin with a visit to Notre-Dame Cathedral, followed by exploring the art and cafés in Montmartre. This plan offers a mix of cultural visits and relaxing experiences.

            Explanation: This response is clear, structured, and provides a concrete itinerary with specific attractions and a suggested order of activities. It is accurate and useful, though it might benefit from a few more details like exact timings or restaurant suggestions to be perfect.


            **Level 5: Fully Adherent**

            **Definition:**
            Response is flawless, accurate, and follows instructions to the letter.

            **Example:**
              **Query:** What is a recommended weekend itinerary in Paris?
              **Response:** Here is a detailed weekend itinerary in Paris:
            Saturday:
            Morning: Begin your day with a visit to the Eiffel Tower to admire the views from the top.
            Early Afternoon: Head to the Louvre for a guided tour of its most famous exhibits.
            Late Afternoon: Take a relaxing walk along the Seine, stopping at local boutiques.
            Evening: Enjoy dinner at a classic Parisian bistro near the river.
            Sunday:
            Morning: Visit the Notre-Dame Cathedral to explore its architecture and history.
            Midday: Wander the charming streets of Montmartre, stopping by art galleries and cafés.
            Afternoon: Finish your trip with a scenic boat tour on the Seine.
            This itinerary balances cultural immersion, leisure, and local dining experiences, ensuring a well-rounded visit.

            Explanation:  This response is comprehensive and meticulously follows the instructions. It provides detailed steps, timings, and a variety of activities that fully address the query, leaving no critical gaps.

            # Data
            Query: {{renderedConversation}}
            Response: {{renderedModelResponse}}
            Tool Definitions: {{renderedToolDefinitions}}

            # Tasks
            ## Please provide your assessment Score for the previous answer. Your output should include the following information:
            - **ThoughtChain**: To improve the reasoning process, Think Step by Step and include a step-by-step explanation of your thought process as you analyze the data based on the definitions. Keep it brief and Start your ThoughtChain with "Let's think step by step:".
            - **Explanation**: a very short explanation of why you think the input data should get that Score.
            - **Score**: based on your previous analysis, provide your Score. The answer you give MUST be an integer score (
              "1",
              "2",
              ...,
            ) based on the categories of the definitions.

            ## Please provide your answers between the tags: <S0>your chain of thoughts</S0>, <S1>your explanation</S1>, <S2>your score</S2>.
            # Output
            """;
    var evaluationInstructions = [chatMessage(ChatRole.system, systemPrompt)];
    return evaluationInstructions;
  }
}

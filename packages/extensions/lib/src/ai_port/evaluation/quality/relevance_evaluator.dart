import '../../abstractions/chat_completion/chat_message.dart';
import '../../abstractions/chat_completion/chat_options.dart';
import '../../abstractions/chat_completion/chat_role.dart';
import '../../open_telemetry_consts.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_diagnostic.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import '../numeric_metric.dart';
import '../utilities/timing_helper.dart';

/// An [Evaluator] that evaluates the 'Relevance' of a response produced by an
/// AI model.
///
/// Remarks: [RelevanceEvaluator] measures an AI system's performance in
/// understanding the input and generating contextually appropriate responses.
/// It returns a [NumericMetric] that contains a score for 'Relevance'. The
/// score is a number between 1 and 5, with 1 indicating a poor score, and 5
/// indicating an excellent score. High relevance scores signify the AI
/// system's understanding of the input and its capability to produce coherent
/// and contextually appropriate outputs. Conversely, low relevance scores
/// indicate that generated responses might be off-topic, lacking in context,
/// or insufficient in addressing the user's intended queries. Note:
/// [RelevanceEvaluator] is an AI-based evaluator that uses an AI model to
/// perform its evaluation. While the prompt that this evaluator uses to
/// perform its evaluation is designed to be model-agnostic, the performance
/// of this prompt (and the resulting evaluation) can vary depending on the
/// model used, and can be especially poor when a smaller / local model is
/// used. The prompt that [RelevanceEvaluator] uses has been tested against
/// (and tuned to work well with) the following models. So, using this
/// evaluator with a model from the following list is likely to produce the
/// best results. (The model to be used can be configured via [ChatClient].)
/// GPT-4o
class RelevanceEvaluator implements Evaluator {
  RelevanceEvaluator();

  final ReadOnlyCollection<String> evaluationMetricNames = [RelevanceMetricName];

  static final ChatOptions _chatOptions;

  /// Gets the [Name] of the [NumericMetric] returned by [RelevanceEvaluator].
  static String get relevanceMetricName {
    return "Relevance";
  }

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse,
    {ChatConfiguration? chatConfiguration, Iterable<EvaluationContext>? additionalContext, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(modelResponse);
    _ = Throw.ifNull(chatConfiguration);
    var metric = numericMetric(relevanceMetricName);
    var result = evaluationResult(metric);
    metric.markAsBuiltIn();
    if (!messages.tryGetUserRequest(out ChatMessage? userRequest) || string.isNullOrWhiteSpace(userRequest.text)) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error(
                    'The ${nameof(messages)} supplied for evaluation did not contain a user request as the last message.'));
      return result;
    }
    if (string.isNullOrWhiteSpace(modelResponse.text)) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error('The ${nameof(modelResponse)} supplied for evaluation was null or empty.'));
      return result;
    }
    var evaluationInstructions = getEvaluationInstructions(userRequest, modelResponse);
    (ChatResponse evaluationResponse, TimeSpan evaluationDuration) =
            await TimingHelper.executeWithTimingAsync(() =>
                chatConfiguration.chatClient.getResponseAsync(
                    evaluationInstructions,
                    _chatOptions,
                    cancellationToken)).configureAwait(false);
    _ = metric.tryParseEvaluationResponseWithTags(evaluationResponse, evaluationDuration);
    metric.interpretation = metric.interpretScore();
    return result;
  }

  static List<ChatMessage> getEvaluationInstructions(
    ChatMessage userRequest,
    ChatResponse modelResponse,
  ) {
    var SystemPrompt = """
            # Instruction
            ## Goal
            ### You are an expert in evaluating the quality of a RESPONSE from an intelligent system based on provided definition and data. Your goal will involve answering the questions below using the information provided.
            - **Definition**: You are given a definition of the communication trait that is being evaluated to help guide your Score.
            - **Data**: Your input data include QUERY and RESPONSE.
            - **Tasks**: To complete your evaluation you will be asked to evaluate the Data in different ways.
            """;
    var evaluationInstructions = [chatMessage(ChatRole.system, SystemPrompt)];
    var renderedUserRequest = userRequest.renderText();
    var renderedModelResponse = modelResponse.renderText();
    var evaluationPrompt = $''"
            # Definition
            **Relevance** refers to how effectively a response addresses a question. It assesses the accuracy, completeness, and direct relevance of the response based solely on the given information.

            # Ratings
            ## [Relevance: 1] (Irrelevant Response)
            **Definition:** The response is unrelated to the question. It provides information that is off-topic and does not attempt to address the question posed.

            **Examples:**
              **Query:** What is the team preparing for?
              **Response:** I went grocery shopping yesterday evening.

              **Query:** When will the company's new product line launch?
              **Response:** International travel can be very rewarding and educational.

            ## [Relevance: 2] (Incorrect Response)
            **Definition:** The response attempts to address the question but includes incorrect information. It provides a response that is factually wrong based on the provided information.

            **Examples:**
              **Query:** When was the merger between the two firms finalized?
              **Response:** The merger was finalized on April 10th.

              **Query:** Where and when will the solar eclipse be visible?
              **Response:** The solar eclipse will be visible in Asia on December 14th.

            ## [Relevance: 3] (Incomplete Response)
            **Definition:** The response addresses the question but omits key details necessary for a full understanding. It provides a partial response that lacks essential information.

            **Examples:**
              **Query:** What type of food does the new restaurant offer?
              **Response:** The restaurant offers Italian food like pasta.

              **Query:** What topics will the conference cover?
              **Response:** The conference will cover renewable energy and climate change.

            ## [Relevance: 4] (Complete Response)
            **Definition:** The response fully addresses the question with accurate and complete information. It includes all essential details required for a comprehensive understanding, without adding any extraneous information.

            **Examples:**
              **Query:** What type of food does the new restaurant offer?
              **Response:** The new restaurant offers Italian cuisine, featuring dishes like pasta, pizza, and risotto.

              **Query:** What topics will the conference cover?
              **Response:** The conference will cover renewable energy, climate change, and sustainability practices.

            ## [Relevance: 5] (Comprehensive Response with Insights)
            **Definition:** The response not only fully and accurately addresses the question but also includes additional relevant insights or elaboration. It may explain the significance, implications, or provide minor inferences that enhance understanding.

            **Examples:**
              **Query:** What type of food does the new restaurant offer?
              **Response:** The new restaurant offers Italian cuisine, featuring dishes like pasta, pizza, and risotto, aiming to provide customers with an authentic Italian dining experience.

              **Query:** What topics will the conference cover?
              **Response:** The conference will cover renewable energy, climate change, and sustainability practices, bringing together global experts to discuss these critical issues.



            # Data
            QUERY: {{renderedUserRequest}}
            RESPONSE: {{renderedModelResponse}}


            # Tasks
            ## Please provide your assessment Score for the previous RESPONSE in relation to the QUERY based on the Definitions above. Your output should include the following information:
            - **ThoughtChain**: To improve the reasoning process, think step by step and include a step-by-step explanation of your thought process as you analyze the data based on the definitions. Keep it brief and start your ThoughtChain with "Let's think step by step:".
            - **Explanation**: a very short explanation of why you think the input Data should get that Score.
            - **Score**: based on your previous analysis, provide your Score. The Score you give MUST be a integer score (
              i.e.,
              "1",
              "2"...,
            ) based on the levels of the definitions.


            ## Please provide your answers between the tags: <S0>your chain of thoughts</S0>, <S1>your explanation</S1>, <S2>your Score</S2>.
            # Output
            """;
    evaluationInstructions.add(chatMessage(ChatRole.user, evaluationPrompt));
    return evaluationInstructions;
  }
}

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
import 'completeness_evaluator_context.dart';

/// An [Evaluator] that evaluates the 'Completeness' of a response produced by
/// an AI model.
///
/// Remarks: [CompletenessEvaluator] measures an AI system's ability to
/// deliver comprehensive and accurate responses. It assesses how thoroughly
/// the response aligns with the key information, claims, and statements
/// established in the supplied [GroundTruth]. It returns a [NumericMetric]
/// that contains a score for 'Completeness'. The score is a number between 1
/// and 5, with 1 indicating a poor score, and 5 indicating an excellent
/// score. Note: [CompletenessEvaluator] is an AI-based evaluator that uses an
/// AI model to perform its evaluation. While the prompt that this evaluator
/// uses to perform its evaluation is designed to be model-agnostic, the
/// performance of this prompt (and the resulting evaluation) can vary
/// depending on the model used, and can be especially poor when a smaller /
/// local model is used. The prompt that [CompletenessEvaluator] uses has been
/// tested against (and tuned to work well with) the following models. So,
/// using this evaluator with a model from the following list is likely to
/// produce the best results. (The model to be used can be configured via
/// [ChatClient].) GPT-4o
class CompletenessEvaluator implements Evaluator {
  CompletenessEvaluator();

  final ReadOnlyCollection<String> evaluationMetricNames = [CompletenessMetricName];

  static final ChatOptions _chatOptions;

  /// Gets the [Name] of the [NumericMetric] returned by
  /// [CompletenessEvaluator].
  static String get completenessMetricName {
    return "Completeness";
  }

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse,
    {ChatConfiguration? chatConfiguration, Iterable<EvaluationContext>? additionalContext, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(modelResponse);
    _ = Throw.ifNull(chatConfiguration);
    var metric = numericMetric(completenessMetricName);
    var result = evaluationResult(metric);
    metric.markAsBuiltIn();
    if (string.isNullOrWhiteSpace(modelResponse.text)) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error('The ${nameof(modelResponse)} supplied for evaluation was null or empty.'));
      return result;
    }
    if (additionalContext?.ofType<CompletenessEvaluatorContext>().firstOrDefault() is! CompletenessEvaluatorContext context) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error(
                    'A value of type ${nameof(CompletenessEvaluatorContext)} was not found in the ${nameof(additionalContext)} collection.'));
      return result;
    }
    var evaluationInstructions = getEvaluationInstructions(modelResponse, context);
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
    ChatResponse modelResponse,
    CompletenessEvaluatorContext context,
  ) {
    var SystemPrompt = """
            # Instruction
            ## Goal
            ### You are an expert in evaluating the quality of a Response from an intelligent system based on provided definition and data. Your goal will involve answering the questions below using the information provided.
            - **Definition**: You are given a definition of the communication trait that is being evaluated to help guide your Score.
            - **Data**: Your input data include Response and Ground Truth.
            - **Tasks**: To complete your evaluation you will be asked to evaluate the Data in different ways.
            """;
    var evaluationInstructions = [chatMessage(ChatRole.system, SystemPrompt)];
    var renderedModelResponse = modelResponse.renderText();
    var groundTruth = context.groundTruth;
    var evaluationPrompt = $''"
            # Definition
            **Completeness** refers to how accurately and thoroughly a response represents the information provided in the ground truth. It considers both the inclusion of all relevant statements and the correctness of those statements. Each statement in the ground truth should be evaluated individually to determine if it is accurately reflected in the response without missing any key information. The scale ranges from 1 to 5, with higher numbers indicating greater completeness.

            # Ratings
            ## [Completeness: 1] (Fully Incomplete)
            **Definition:** A response that does not contain any of the necessary and relevant information with respect to the ground truth. It completely misses all the information, especially claims and statements, established in the ground truth.

            **Examples:**
              **Response:** "Flu shot cannot cure cancer. Stay healthy requires sleeping exactly 8 hours a day. A few hours of exercise per week will have little benefits for physical and mental health. Physical and mental health benefits are separate topics. Scientists have not studied any of them."
              **Ground Truth:** "Flu shot can prevent flu-related illnesses. Staying healthy requires proper hydration and moderate exercise. Even a few hours of exercise per week can have long-term benefits for physical and mental health. This is because physical and mental health benefits have intricate relationships through behavioral changes. Scientists are starting to discover them through rigorous studies."

            ## [Completeness: 2] (Barely Complete)
            **Definition:** A response that contains only a small percentage of all the necessary and relevant information with respect to the ground truth. It misses almost all the information, especially claims and statements, established in the ground truth.

            **Examples:**
              **Response:** "Flu shot can prevent flu-related illnesses. Staying healthy requires 2 meals a day. Exercise per week makes no difference to physical and mental health. This is because physical and mental health benefits have low correlation through scientific studies. Scientists are making this observation in studies."
              **Ground Truth:** "Flu shot can prevent flu-related illnesses. Stay healthy by proper hydration and moderate exercise. Even a few hours of exercise per week can have long-term benefits for physical and mental health. This is because physical and mental health benefits have intricate relationships through behavioral changes. Scientists are starting to discover them through rigorous studies."

            ## [Completeness: 3] (Moderately Complete)
            **Definition:** A response that contains half of the necessary and relevant information with respect to the ground truth. It misses half of the information, especially claims and statements, established in the ground truth.

            **Examples:**
              **Response:** "Flu shot can prevent flu-related illnesses. Staying healthy requires a few dollars of investments a day. Even a few dollars of investments per week will not make an impact on physical and mental health. This is because physical and mental health benefits have intricate relationships through behavioral changes. Fiction writers are starting to discover them through their works."
              **Ground Truth:** "Flu shot can prevent flu-related illnesses. Stay healthy by proper hydration and moderate exercise. Even a few hours of exercise per week can have long-term benefits for physical and mental health. This is because physical and mental health benefits have intricate relationships through behavioral changes. Scientists are starting to discover them through rigorous studies."

            ## [Completeness: 4] (Mostly Complete)
            **Definition:** A response that contains most of the necessary and relevant information with respect to the ground truth. It misses some minor information, especially claims and statements, established in the ground truth.

            **Examples:**
              **Response:** "Flu shot can prevent flu-related illnesses. Staying healthy requires keto diet and rigorous athletic training. Even a few hours of exercise per week can have long-term benefits for physical and mental health. This is because physical and mental health benefits have intricate relationships through behavioral changes. Scientists are starting to discover them through rigorous studies."
              **Ground Truth:** "Flu shot can prevent flu-related illnesses. Stay healthy by proper hydration and moderate exercise. Even a few hours of exercise per week can have long-term benefits for physical and mental health. This is because physical and mental health benefits have intricate relationships through behavioral changes. Scientists are starting to discover them through rigorous studies."

            ## [Completeness: 5] (Fully Complete)
            **Definition:** A response that perfectly contains all the necessary and relevant information with respect to the ground truth. It does not miss any information from statements and claims in the ground truth.

            **Examples:**
              **Response:** "Flu shot can prevent flu-related illnesses. Stay healthy by proper hydration and moderate exercise. Even a few hours of exercise per week can have long-term benefits for physical and mental health. This is because physical and mental health benefits have intricate relationships through behavioral changes. Scientists are starting to discover them through rigorous studies."
              **Ground Truth:** "Flu shot can prevent flu-related illnesses. Stay healthy by proper hydration and moderate exercise. Even a few hours of exercise per week can have long-term benefits for physical and mental health. This is because physical and mental health benefits have intricate relationships through behavioral changes. Scientists are starting to discover them through rigorous studies."


            # Data
            Response: {{renderedModelResponse}}
            Ground Truth: {{groundTruth}}


            # Tasks
            ## Please provide your assessment Score for the previous RESPONSE in relation to the GROUND TRUTH based on the Definitions above. Your output should include the following information:
            - **ThoughtChain**: To improve the reasoning process, think step by step and include a step-by-step explanation of your thought process as you analyze the data based on the definitions. Keep it brief and start your ThoughtChain with "Let's think step by step:".
            - **Explanation**: a very short explanation of why you think the input data should get that Score.
            - **Score**: based on your previous analysis, provide your Score. The Score you give MUST be an integer score (
              i.e.,
              "1",
              "2"...,
            ) based on the levels of the definitions.

            ## Please provide your answers between the tags: <S0>your chain of thoughts</S0>, <S1>your explanation</S1>, <S2>your score</S2>.
            # Output
            """;
    evaluationInstructions.add(chatMessage(ChatRole.user, evaluationPrompt));
    return evaluationInstructions;
  }
}

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

/// An [Evaluator] that evaluates the 'Fluency' of a response produced by an
/// AI model.
///
/// Remarks: [FluencyEvaluator] measures the extent to which the response
/// being evaluated is linguistically correct (i.e., conforms to grammatical
/// rules, syntactic structures, and appropriate vocabulary usage). It returns
/// a [NumericMetric] that contains a score for 'Fluency'. The score is a
/// number between 1 and 5, with 1 indicating a poor score, and 5 indicating
/// an excellent score. Note: [FluencyEvaluator] is an AI-based evaluator that
/// uses an AI model to perform its evaluation. While the prompt that this
/// evaluator uses to perform its evaluation is designed to be model-agnostic,
/// the performance of this prompt (and the resulting evaluation) can vary
/// depending on the model used, and can be especially poor when a smaller /
/// local model is used. The prompt that [FluencyEvaluator] uses has been
/// tested against (and tuned to work well with) the following models. So,
/// using this evaluator with a model from the following list is likely to
/// produce the best results. (The model to be used can be configured via
/// [ChatClient].) GPT-4o
class FluencyEvaluator implements Evaluator {
  FluencyEvaluator();

  final ReadOnlyCollection<String> evaluationMetricNames = [FluencyMetricName];

  static final ChatOptions _chatOptions;

  /// Gets the [Name] of the [NumericMetric] returned by [FluencyEvaluator].
  static String get fluencyMetricName {
    return "Fluency";
  }

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse,
    {ChatConfiguration? chatConfiguration, Iterable<EvaluationContext>? additionalContext, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(modelResponse);
    _ = Throw.ifNull(chatConfiguration);
    var metric = numericMetric(fluencyMetricName);
    var result = evaluationResult(metric);
    metric.markAsBuiltIn();
    if (string.isNullOrWhiteSpace(modelResponse.text)) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error('The ${nameof(modelResponse)} supplied for evaluation was null or empty.'));
      return result;
    }
    var evaluationInstructions = getEvaluationInstructions(modelResponse);
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

  static List<ChatMessage> getEvaluationInstructions(ChatResponse modelResponse) {
    var SystemPrompt = """
            # Instruction
            ## Goal
            ### You are an expert in evaluating the quality of a RESPONSE from an intelligent system based on provided definition and data. Your goal will involve answering the questions below using the information provided.
            - **Definition**: You are given a definition of the communication trait that is being evaluated to help guide your Score.
            - **Data**: Your input data include a RESPONSE.
            - **Tasks**: To complete your evaluation you will be asked to evaluate the Data in different ways.
            """;
    var evaluationInstructions = [chatMessage(ChatRole.system, SystemPrompt)];
    var renderedModelResponse = modelResponse.renderText();
    var evaluationPrompt = $''"
            # Definition
            **Fluency** refers to the effectiveness and clarity of written communication, focusing on grammatical accuracy, vocabulary range, sentence complexity, coherence, and overall readability. It assesses how smoothly ideas are conveyed and how easily the text can be understood by the reader.

            # Ratings
            ## [Fluency: 1] (Emergent Fluency)
            **Definition:** The response shows minimal command of the language. It contains pervasive grammatical errors, extremely limited vocabulary, and fragmented or incoherent sentences. The message is largely incomprehensible, making understanding very difficult.

            **Examples:**
              **Response:** Free time I. Go park. Not fun. Alone.

              **Response:** Like food pizza. Good cheese eat.

            ## [Fluency: 2] (Basic Fluency)
            **Definition:** The response communicates simple ideas but has frequent grammatical errors and limited vocabulary. Sentences are short and may be improperly constructed, leading to partial understanding. Repetition and awkward phrasing are common.

            **Examples:**
              **Response:** I like play soccer. I watch movie. It fun.

              **Response:** My town small. Many people. We have market.

            ## [Fluency: 3] (Competent Fluency)
            **Definition:** The response clearly conveys ideas with occasional grammatical errors. Vocabulary is adequate but not extensive. Sentences are generally correct but may lack complexity and variety. The text is coherent, and the message is easily understood with minimal effort.

            **Examples:**
              **Response:** I'm planning to visit friends and maybe see a movie together.

              **Response:** I try to eat healthy food and exercise regularly by jogging.

            ## [Fluency: 4] (Proficient Fluency)
            **Definition:** The response is well-articulated with good control of grammar and a varied vocabulary. Sentences are complex and well-structured, demonstrating coherence and cohesion. Minor errors may occur but do not affect overall understanding. The text flows smoothly, and ideas are connected logically.

            **Examples:**
              **Response:** My interest in mathematics and problem-solving inspired me to become an engineer, as I enjoy designing solutions that improve people's lives.

              **Response:** Environmental conservation is crucial because it protects ecosystems, preserves biodiversity, and ensures natural resources are available for future generations.

            ## [Fluency: 5] (Exceptional Fluency)
            **Definition:** The response demonstrates an exceptional command of language with sophisticated vocabulary and complex, varied sentence structures. It is coherent, cohesive, and engaging, with precise and nuanced expression. Grammar is flawless, and the text reflects a high level of eloquence and style.

            **Examples:**
              **Response:** Globalization exerts a profound influence on cultural diversity by facilitating unprecedented cultural exchange while simultaneously risking the homogenization of distinct cultural identities, which can diminish the richness of global heritage.

              **Response:** Technology revolutionizes modern education by providing interactive learning platforms, enabling personalized learning experiences, and connecting students worldwide, thereby transforming how knowledge is acquired and shared.


            # Data
            RESPONSE: {{renderedModelResponse}}


            # Tasks
            ## Please provide your assessment Score for the previous RESPONSE based on the Definitions above. Your output should include the following information:
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

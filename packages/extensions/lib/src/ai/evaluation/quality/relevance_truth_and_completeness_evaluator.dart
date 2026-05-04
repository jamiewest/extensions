import 'package:extensions/annotations.dart';

import '../../../system/threading/cancellation_token.dart';
import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_options.dart';
import '../../chat_completion/chat_response.dart';
import '../../chat_completion/chat_role.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_diagnostic.dart';
import '../evaluation_metric_extensions.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import '../numeric_metric.dart';
import 'relevance_truth_and_completeness_rating.dart';

/// Evaluates an AI response on three dimensions — Relevance, Truth, and
/// Completeness — in a single model call, returning one [NumericMetric] per
/// dimension (each scored 1–5).
///
/// Requires a [ChatConfiguration]; unlike other quality evaluators this one
/// asks the model to respond with a JSON object rather than XML score tags.
@Source(
  name: 'RelevanceTruthAndCompletenessEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class RelevanceTruthAndCompletenessEvaluator implements Evaluator {
  /// The name of the Relevance [NumericMetric] returned by this evaluator.
  static const String relevanceMetricName = 'Relevance';

  /// The name of the Truth [NumericMetric] returned by this evaluator.
  static const String truthMetricName = 'Truth';

  /// The name of the Completeness [NumericMetric] returned by this evaluator.
  static const String completenessMetricName = 'Completeness';

  static final _chatOptions = ChatOptions(temperature: 0);

  @override
  List<String> get evaluationMetricNames => const [
        relevanceMetricName,
        truthMetricName,
        completenessMetricName,
      ];

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async {
    final relevance = NumericMetric(relevanceMetricName);
    final truth = NumericMetric(truthMetricName);
    final completeness = NumericMetric(completenessMetricName);
    final result =
        EvaluationResult.fromList([relevance, truth, completeness]);

    if (chatConfiguration == null) {
      const msg =
          'chatConfiguration is required for AI-based evaluators.';
      relevance.addDiagnostic(EvaluationDiagnostic.error(msg));
      truth.addDiagnostic(EvaluationDiagnostic.error(msg));
      completeness.addDiagnostic(EvaluationDiagnostic.error(msg));
      return result;
    }

    if (modelResponse.text.isEmpty) {
      const msg =
          'The modelResponse supplied for evaluation was null or empty.';
      relevance.addDiagnostic(EvaluationDiagnostic.error(msg));
      truth.addDiagnostic(EvaluationDiagnostic.error(msg));
      completeness.addDiagnostic(EvaluationDiagnostic.error(msg));
      return result;
    }

    final msgList = messages.toList();
    final lastUser = msgList.cast<ChatMessage?>().lastWhere(
          (m) => m?.role == ChatRole.user,
          orElse: () => null,
        );

    if (lastUser == null || lastUser.text.isEmpty) {
      const msg = 'No user message found in the conversation history.';
      relevance.addDiagnostic(EvaluationDiagnostic.error(msg));
      truth.addDiagnostic(EvaluationDiagnostic.error(msg));
      completeness.addDiagnostic(EvaluationDiagnostic.error(msg));
      return result;
    }

    final history =
        msgList.where((m) => m != lastUser).map((m) => m.text).join('\n');
    final instructions =
        _buildPrompt(lastUser.text, modelResponse.text, history);

    final start = DateTime.now();
    final evalResponse =
        await chatConfiguration.chatClient.getResponse(
      messages: [ChatMessage.fromText(ChatRole.user, instructions)],
      options: _chatOptions,
      cancellationToken: cancellationToken,
    );
    final duration = DateTime.now().difference(start);

    final rating =
        RelevanceTruthAndCompletenessRating.tryParse(evalResponse.text);

    if (rating == null || rating.isInconclusive) {
      const msg = 'Could not parse scores from the evaluation response.';
      relevance.addDiagnostic(EvaluationDiagnostic.error(msg));
      truth.addDiagnostic(EvaluationDiagnostic.error(msg));
      completeness.addDiagnostic(EvaluationDiagnostic.error(msg));
      return result;
    }

    relevance.value = rating.relevance.toDouble();
    relevance.reason = rating.relevanceReasoning;
    relevance.addOrUpdateChatMetadata(evalResponse, duration: duration);
    relevance.interpretation = relevance.interpretScore();

    truth.value = rating.truth.toDouble();
    truth.reason = rating.truthReasoning;
    truth.addOrUpdateChatMetadata(evalResponse, duration: duration);
    truth.interpretation = truth.interpretScore();

    completeness.value = rating.completeness.toDouble();
    completeness.reason = rating.completenessReasoning;
    completeness.addOrUpdateChatMetadata(evalResponse, duration: duration);
    completeness.interpretation = completeness.interpretScore();

    return result;
  }

  static String _buildPrompt(
    String userRequest,
    String modelResponseText,
    String conversationHistory,
  ) =>
      '''
Read the History, User Query, and Model Response below and produce your response as a single JSON object.
Do not include any other text in your response besides the JSON object. Make sure the response is a valid
JSON object.

The JSON object should have the following format. However, do not include any markdown tags in your
response. Your response should start with an open curly brace and end with a closing curly brace for the JSON.
```
{
    "relevance": 1,
    "relevanceReasoning": "The reason for the relevance score",
    "relevanceReasons": ["relevance_reason_distant_topic"],
    "truth": 1,
    "truthReasoning": "The reason for the truth score",
    "truthReasons": ["truth_reason_incorrect_information", "truth_reason_outdated_information"],
    "completeness": 1,
    "completenessReasoning": "The reason for the completeness score",
    "completenessReasons": ["completeness_reason_no_solution"]
}
```

-----

History: $conversationHistory

-----

User Query: $userRequest

-----

Model Response: $modelResponseText

-----

That's the History, User Query, and Model Response you will rate. Now, in 3 Steps, you will evaluate the Model Response on 3 criteria.

-----

Step 1: Rate the relevance of the response.

Regardless of truth of statements, how much of the response is directly related to the request?

1 = None of the response is at all related
2 = A little of the response is directly related, or the response is a little bit related
3 = Some of the response is related, or the response is somewhat related
4 = Most of the response is related, or the response is mostly related
5 = 100% of the response is 100% related to the request

Step 1a. Record your response as the value of the "relevance" property in the JSON output.

Step 1b. Now, record your reasoning for that score as the value of the "relevanceReasoning" property. If the score is 5, record the value of "relevanceReasoning" as "100% of the response is 100% related to the request". If the score is not 5, write your Reasoning as fewer than 100 words and prioritizing the most important contributing reasons to the score.

Step 1c. Now, record whether your relevance reasoning includes each of these categories, as an array of strings for the value of the "relevanceReasons" property. The possible values for this array are "relevance_reason_distant_topic", "relevance_reason_scope_too_small", "relevance_reason_scope_too_large", "relevance_reason_wrong_intent_served", or "relevance_reason_other". If the score is 5, the array should be empty.

-----

Step 2: Rate the truth of the response.

Read the History, Query, and Model Response again.

Regardless of relevance, how true are the verifiable statements in the response?

1 = The entire response is totally false
2 = A little of the response is true, or the response is a little bit true
3 = Some of the response is true, or the response is somewhat true
4 = Most of the response is true, or the response is mostly true
5 = 100% of the response is 100% true

Step 2a. Record your response as the value of the "truth" property in the JSON output.

Step 2b. Now, record your reasoning for that score as the value of the "truthReasoning" property. If the score is 5, record the value of "truthReasoning" as "100% of the response is 100% true". If the score is not 5, write your Reasoning as fewer than 100 words and prioritizing the most important contributing reasons to the score.

Step 2c. Now, record whether your truth reasoning includes each of these categories, as an array of strings for the value of the "truthReasons" property. The possible values for this array are "truth_reason_incorrect_information", "truth_reason_outdated_information", "truth_reason_misleading_incorrectforintent", or "truth_reason_other". If the score is 5, the array should be empty.

-----

Step 3: Rate the completeness of the response.

Read the History, Query, and Model Response again.

Regardless of whether the statements made in the response are true, how many of the points necessary to address the request, does the response contain?

1 = The response omits all points that are necessary to address the request.
2 = The response includes a little of the points that are necessary to address the request.
3 = The response includes some of the points that are necessary to address the request.
4 = The response includes most of the points that are necessary to address the request.
5 = The response includes all points that are necessary to address the request.

Step 3a. Record your response as the value of the "completeness" property in the JSON output.

Step 3b. Now, record your reasoning for that score as the value of the "completenessReasoning" property. If the score is 5, record the value of "completenessReasoning" as "The response includes all points that are necessary to address the request". If the score is not 5, write your Reasoning as fewer than 100 words and prioritizing the most important contributing reasons to the score.

Step 3c. Now, record whether your completeness reasoning includes each of these categories, as an array of strings for the value of the "completenessReasons" property. The possible values for this array are "completeness_reason_no_solution", "completeness_reason_lacks_information_about_solution", "completeness_reason_genericsolution_missingcode", "completeness_reason_generic_code", "completeness_reason_failed_to_change_code", "completeness_reason_incomplete_list", "completeness_reason_incomplete_code", "completeness_reason_missing_warnings", or "completeness_reason_other". If the score is 5, the array should be empty.
''';
}

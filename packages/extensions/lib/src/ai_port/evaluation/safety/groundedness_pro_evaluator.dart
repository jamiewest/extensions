import '../../abstractions/chat_completion/chat_message.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import '../numeric_metric.dart';
import 'content_safety_evaluator.dart';
import 'content_safety_service_payload_format.dart';
import 'groundedness_pro_evaluator_context.dart';

/// An [Evaluator] that utilizes the Azure AI Foundry Evaluation service to
/// evaluate the groundedness of responses produced by an AI model.
///
/// Remarks: The [GroundednessProEvaluator] measures the degree to which the
/// response being evaluated is grounded in the information present in the
/// supplied [GroundingContext]. It returns a [NumericMetric] that contains a
/// score for the groundedness. The score is a number between 1 and 5, with 1
/// indicating a poor score, and 5 indicating an excellent score. Note that
/// [GroundednessProEvaluator] does not support evaluation of multimodal
/// content present in the evaluated responses. Images and other multimodal
/// content present in the evaluated responses will be ignored. Also note that
/// if a multi-turn conversation is supplied as input,
/// [GroundednessProEvaluator] will only evaluate the contents of the last
/// conversation turn. The contents of previous conversation turns will be
/// ignored. The Azure AI Foundry Evaluation service uses a finetuned model to
/// perform this evaluation which is expected to produce more accurate results
/// than similar evaluations performed using a regular (non-finetuned) model.
class GroundednessProEvaluator extends ContentSafetyEvaluator {
  /// An [Evaluator] that utilizes the Azure AI Foundry Evaluation service to
  /// evaluate the groundedness of responses produced by an AI model.
  ///
  /// Remarks: The [GroundednessProEvaluator] measures the degree to which the
  /// response being evaluated is grounded in the information present in the
  /// supplied [GroundingContext]. It returns a [NumericMetric] that contains a
  /// score for the groundedness. The score is a number between 1 and 5, with 1
  /// indicating a poor score, and 5 indicating an excellent score. Note that
  /// [GroundednessProEvaluator] does not support evaluation of multimodal
  /// content present in the evaluated responses. Images and other multimodal
  /// content present in the evaluated responses will be ignored. Also note that
  /// if a multi-turn conversation is supplied as input,
  /// [GroundednessProEvaluator] will only evaluate the contents of the last
  /// conversation turn. The contents of previous conversation turns will be
  /// ignored. The Azure AI Foundry Evaluation service uses a finetuned model to
  /// perform this evaluation which is expected to produce more accurate results
  /// than similar evaluations performed using a regular (non-finetuned) model.
  const GroundednessProEvaluator();

  /// Gets the [Name] of the [NumericMetric] returned by
  /// [GroundednessProEvaluator].
  static String get groundednessProMetricName {
    return "Groundedness Pro";
  }

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async {
    _ = Throw.ifNull(chatConfiguration);
    _ = Throw.ifNull(modelResponse);
    var result = await evaluateContentSafetyAsync(
      chatConfiguration.chatClient,
      messages,
      modelResponse,
      additionalContext,
      contentSafetyServicePayloadFormat: ContentSafetyServicePayloadFormat
          .questionAnswer
          .toString(),
      cancellationToken: cancellationToken,
    ).configureAwait(false);
    var context = getRelevantContext(additionalContext);
    result.addOrUpdateContextInAllMetrics(context);
    return result;
  }

  @override
  List<EvaluationContext>? filterAdditionalContext(
    Iterable<EvaluationContext>? additionalContext,
  ) {
    var context = getRelevantContext(additionalContext);
    return [context];
  }

  static GroundednessProEvaluatorContext getRelevantContext(
    Iterable<EvaluationContext>? additionalContext,
  ) {
    if (additionalContext
            ?.ofType<GroundednessProEvaluatorContext>()
            .firstOrDefault()
        is GroundednessProEvaluatorContext) {
      final context =
          additionalContext
                  ?.ofType<GroundednessProEvaluatorContext>()
                  .firstOrDefault()
              as GroundednessProEvaluatorContext;
      return context;
    }
    throw invalidOperationException(
      'A value of type ${nameof(GroundednessProEvaluatorContext)} was not found in the ${nameof(additionalContext)} collection.',
    );
  }
}

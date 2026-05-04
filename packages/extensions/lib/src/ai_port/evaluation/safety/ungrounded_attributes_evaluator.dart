import '../../abstractions/chat_completion/chat_message.dart';
import '../boolean_metric.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import 'content_safety_evaluator.dart';
import 'content_safety_service_payload_format.dart';
import 'ungrounded_attributes_evaluator_context.dart';

/// An [Evaluator] that utilizes the Azure AI Foundry Evaluation service to
/// evaluate responses produced by an AI model for presence of content that
/// indicates ungrounded inference of human attributes.
///
/// Remarks: The [UngroundedAttributesEvaluator] checks whether the response
/// being evaluated is first, ungrounded based on the information present in
/// the supplied [GroundingContext]. It then checks whether the response
/// contains information about the protected class or emotional state of a
/// person. It returns a [BooleanMetric] with a value of `false` indicating an
/// excellent score, and a value of `true` indicating a poor score. Note that
/// [UngroundedAttributesEvaluator] does not support evaluation of multimodal
/// content present in the evaluated responses. Images and other multimodal
/// content present in the evaluated responses will be ignored. Also note that
/// if a multi-turn conversation is supplied as input,
/// [UngroundedAttributesEvaluator] will only evaluate the contents of the
/// last conversation turn. The contents of previous conversation turns will
/// be ignored. The Azure AI Foundry Evaluation service uses a finetuned model
/// to perform this evaluation which is expected to produce more accurate
/// results than similar evaluations performed using a regular (non-finetuned)
/// model.
class UngroundedAttributesEvaluator extends ContentSafetyEvaluator {
  /// An [Evaluator] that utilizes the Azure AI Foundry Evaluation service to
  /// evaluate responses produced by an AI model for presence of content that
  /// indicates ungrounded inference of human attributes.
  ///
  /// Remarks: The [UngroundedAttributesEvaluator] checks whether the response
  /// being evaluated is first, ungrounded based on the information present in
  /// the supplied [GroundingContext]. It then checks whether the response
  /// contains information about the protected class or emotional state of a
  /// person. It returns a [BooleanMetric] with a value of `false` indicating an
  /// excellent score, and a value of `true` indicating a poor score. Note that
  /// [UngroundedAttributesEvaluator] does not support evaluation of multimodal
  /// content present in the evaluated responses. Images and other multimodal
  /// content present in the evaluated responses will be ignored. Also note that
  /// if a multi-turn conversation is supplied as input,
  /// [UngroundedAttributesEvaluator] will only evaluate the contents of the
  /// last conversation turn. The contents of previous conversation turns will
  /// be ignored. The Azure AI Foundry Evaluation service uses a finetuned model
  /// to perform this evaluation which is expected to produce more accurate
  /// results than similar evaluations performed using a regular (non-finetuned)
  /// model.
  const UngroundedAttributesEvaluator();

  /// Gets the [Name] of the [BooleanMetric] returned by
  /// [UngroundedAttributesEvaluator].
  static String get ungroundedAttributesMetricName {
    return "Ungrounded Attributes";
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
          .queryResponse
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

  static UngroundedAttributesEvaluatorContext getRelevantContext(
    Iterable<EvaluationContext>? additionalContext,
  ) {
    if (additionalContext
            ?.ofType<UngroundedAttributesEvaluatorContext>()
            .firstOrDefault()
        is UngroundedAttributesEvaluatorContext) {
      final context =
          additionalContext
                  ?.ofType<UngroundedAttributesEvaluatorContext>()
                  .firstOrDefault()
              as UngroundedAttributesEvaluatorContext;
      return context;
    }
    throw invalidOperationException(
      'A value of type ${nameof(UngroundedAttributesEvaluatorContext)} was not found in the ${nameof(additionalContext)} collection.',
    );
  }
}

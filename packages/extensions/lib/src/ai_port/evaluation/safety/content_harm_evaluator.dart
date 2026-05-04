import '../../abstractions/chat_completion/chat_message.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import '../numeric_metric.dart';
import 'content_safety_evaluator.dart';
import 'content_safety_service_payload_format.dart';
import 'hate_and_unfairness_evaluator.dart';
import 'self_harm_evaluator.dart';
import 'sexual_evaluator.dart';
import 'violence_evaluator.dart';

/// An [Evaluator] that utilizes the Azure AI Foundry Evaluation service to
/// evaluate responses produced by an AI model for the presence of a variety
/// of harmful content such as violence, hate speech, etc.
///
/// Remarks: [ContentHarmEvaluator] can be used to evaluate responses for all
/// supported content harm metrics in one go. You can achieve this by omitting
/// the `metricNames` parameter. [ContentHarmEvaluator] also serves as a base
/// class for [HateAndUnfairnessEvaluator], [ViolenceEvaluator],
/// [SelfHarmEvaluator] and [SexualEvaluator] which can be used to evaluate
/// responses for one specific content harm metric at a time.
///
/// [metricNames] A optional dictionary containing the mapping from the names
/// of the metrics that are used when communicating with the Azure AI Foundry
/// Evaluation service, to the [Name]s of the [EvaluationMetric]s returned by
/// this [Evaluator]. If omitted, includes mappings for all content harm
/// metrics that are supported by the Azure AI Foundry Evaluation service.
/// This includes [HateAndUnfairnessMetricName], [ViolenceMetricName],
/// [SelfHarmMetricName] and [SexualMetricName].
class ContentHarmEvaluator extends ContentSafetyEvaluator {
  /// An [Evaluator] that utilizes the Azure AI Foundry Evaluation service to
  /// evaluate responses produced by an AI model for the presence of a variety
  /// of harmful content such as violence, hate speech, etc.
  ///
  /// Remarks: [ContentHarmEvaluator] can be used to evaluate responses for all
  /// supported content harm metrics in one go. You can achieve this by omitting
  /// the `metricNames` parameter. [ContentHarmEvaluator] also serves as a base
  /// class for [HateAndUnfairnessEvaluator], [ViolenceEvaluator],
  /// [SelfHarmEvaluator] and [SexualEvaluator] which can be used to evaluate
  /// responses for one specific content harm metric at a time.
  ///
  /// [metricNames] A optional dictionary containing the mapping from the names
  /// of the metrics that are used when communicating with the Azure AI Foundry
  /// Evaluation service, to the [Name]s of the [EvaluationMetric]s returned by
  /// this [Evaluator]. If omitted, includes mappings for all content harm
  /// metrics that are supported by the Azure AI Foundry Evaluation service.
  /// This includes [HateAndUnfairnessMetricName], [ViolenceMetricName],
  /// [SelfHarmMetricName] and [SexualMetricName].
  ContentHarmEvaluator({Map<String, String>? metricNames = null});

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse,
    {ChatConfiguration? chatConfiguration, Iterable<EvaluationContext>? additionalContext, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(chatConfiguration);
    _ = Throw.ifNull(modelResponse);
    var result = await evaluateContentSafetyAsync(
                chatConfiguration.chatClient,
                messages,
                modelResponse,
                additionalContext,
                contentSafetyServicePayloadFormat: ContentSafetyServicePayloadFormat.conversation.toString(),
                cancellationToken: cancellationToken).configureAwait(false);
    result.interpret(
            (metric) => metric is NumericMetric numericMetric ? numericMetric.interpretContentHarmScore() : null);
    return result;
  }
}

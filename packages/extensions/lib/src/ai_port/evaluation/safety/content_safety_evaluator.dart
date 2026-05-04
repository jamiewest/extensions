import '../../abstractions/chat_completion/chat_client.dart';
import '../../abstractions/chat_completion/chat_message.dart';
import '../../abstractions/chat_completion/chat_role.dart';
import '../../abstractions/contents/ai_content.dart';
import '../../abstractions/contents/text_content.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_diagnostic.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import '../utilities/timing_helper.dart';
import 'content_safety_chat_options.dart';
import 'content_safety_service_payload_format.dart';
import 'content_safety_service_payload_utilities.dart';

/// An `abstract` base class that can be used to implement [Evaluator]s that
/// utilize the Azure AI Foundry Evaluation service to evaluate responses
/// produced by an AI model for the presence of a variety of unsafe content
/// such as protected material, vulnerable code, harmful content etc.
///
/// [contentSafetyServiceAnnotationTask] The name of the annotation task that
/// should be used when communicating with the Azure AI Foundry Evaluation
/// service to perform evaluations.
///
/// [metricNames] A dictionary containing the mapping from the names of the
/// metrics that are used when communicating with the Azure AI Foundry
/// Evaluation service, to the [Name]s of the [EvaluationMetric]s returned by
/// this [Evaluator].
abstract class ContentSafetyEvaluator implements Evaluator {
  /// An `abstract` base class that can be used to implement [Evaluator]s that
  /// utilize the Azure AI Foundry Evaluation service to evaluate responses
  /// produced by an AI model for the presence of a variety of unsafe content
  /// such as protected material, vulnerable code, harmful content etc.
  ///
  /// [contentSafetyServiceAnnotationTask] The name of the annotation task that
  /// should be used when communicating with the Azure AI Foundry Evaluation
  /// service to perform evaluations.
  ///
  /// [metricNames] A dictionary containing the mapping from the names of the
  /// metrics that are used when communicating with the Azure AI Foundry
  /// Evaluation service, to the [Name]s of the [EvaluationMetric]s returned by
  /// this [Evaluator].
  const ContentSafetyEvaluator(
    String contentSafetyServiceAnnotationTask,
    Map<String, String> metricNames,
  );

  final ReadOnlyCollection<String> evaluationMetricNames = [.. metricNames.Values];

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse,
    {ChatConfiguration? chatConfiguration, Iterable<EvaluationContext>? additionalContext, CancellationToken? cancellationToken, },
  ) {
    _ = Throw.ifNull(chatConfiguration);
    return evaluateContentSafetyAsync(
            chatConfiguration.chatClient,
            messages,
            modelResponse,
            additionalContext,
            cancellationToken: cancellationToken);
  }

  /// Evaluates the supplied `modelResponse` using the Azure AI Foundry
  /// Evaluation Service and returns an [EvaluationResult] containing one or
  /// more [EvaluationMetric]s.
  ///
  /// Returns: An [EvaluationResult] containing one or more [EvaluationMetric]s.
  ///
  /// [contentSafetyServiceChatClient] The [ChatClient] that should be used to
  /// communicate with the Azure AI Foundry Evaluation Service when performing
  /// evaluations.
  ///
  /// [messages] The conversation history including the request that produced
  /// the supplied `modelResponse`.
  ///
  /// [modelResponse] The response that is to be evaluated.
  ///
  /// [additionalContext] Additional contextual information (beyond that which
  /// is available in `messages`) that the [Evaluator] may need to accurately
  /// evaluate the supplied `modelResponse`.
  ///
  /// [contentSafetyServicePayloadFormat] An identifier that specifies the
  /// format of the payload that should be used when communicating with the
  /// Azure AI Foundry Evaluation service to perform evaluations.
  ///
  /// [includeMetricNamesInContentSafetyServicePayload] A [Boolean] flag that
  /// indicates whether the names of the metrics should be included in the
  /// payload that is sent to the Azure AI Foundry Evaluation service when
  /// performing evaluations.
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the evaluation
  /// operation.
  Future<EvaluationResult> evaluateContentSafety(
    ChatClient contentSafetyServiceChatClient,
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse,
    {Iterable<EvaluationContext>? additionalContext, String? contentSafetyServicePayloadFormat, bool? includeMetricNamesInContentSafetyServicePayload, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(contentSafetyServiceChatClient);
    _ = Throw.ifNull(modelResponse);
    var payloadFormat = #if NET
            Enum.parse<ContentSafetyServicePayloadFormat>(contentSafetyServicePayloadFormat);
    #else
            (ContentSafetyServicePayloadFormat)Enum.parse(
                typeof(ContentSafetyServicePayloadFormat),
                contentSafetyServicePayloadFormat);
    var conversation = [.. messages, .. modelResponse.messages];
    var evaluatorName = getType().name;
    var perTurnContext = null;
    if (additionalContext != null && additionalContext.any()) {
      var relevantContext = filterAdditionalContext(additionalContext);
      if (relevantContext != null && relevantContext.any() &&
                relevantContext.selectMany((c) => c.contents) is IEnumerable<AContent> contents && contents.any() &&
                contents.ofType<TextContent>() is IEnumerable<TextContent> textContents && textContents.any() &&
                string.join(
                  Environment.newLine,
                  textContents.select((c) => c.text),
                ) is string contextString &&
                !string.isNullOrWhiteSpace(contextString)) {
        // Currently we only support supplying a context for the last conversation turn (which is the main one
                // that is being evaluated).
                perTurnContext = [contextString];
      }
    }
    (string payload, IReadOnlyList<EvaluationDiagnostic>? diagnostics) =
            ContentSafetyServicePayloadUtilities.getPayload(
                payloadFormat,
                conversation,
                contentSafetyServiceAnnotationTask,
                evaluatorName,
                perTurnContext,
                metricNames: includeMetricNamesInContentSafetyServicePayload ? metricNames.keys : null,
                cancellationToken);
    var payloadMessage = chatMessage(ChatRole.user, payload);
    (ChatResponse annotationResponse, TimeSpan annotationDuration) =
            await TimingHelper.executeWithTimingAsync(() =>
                contentSafetyServiceChatClient.getResponseAsync(
                    payloadMessage,
                    options: contentSafetyChatOptions(
                      contentSafetyServiceAnnotationTask,
                      evaluatorName,
                    ),
                    cancellationToken: cancellationToken)).configureAwait(false);
    var annotationResult = annotationResponse.text;
    var result = ContentSafetyService.parseAnnotationResult(annotationResult);
    var updatedResult = updateMetrics();
    return updatedResult;
    /* TODO: unsupported node kind "unknown" */
    // EvaluationResult UpdateMetrics()
    //         {
      //             EvaluationResult updatedResult = new EvaluationResult();
      //
      //             foreach (EvaluationMetric metric in result.Metrics.Values)
      //             {
        //                 string contentSafetyServiceMetricName = metric.Name;
        //                 if (metricNames.TryGetValue(contentSafetyServiceMetricName, out string? metricName))
        //                 {
          //                     metric.Name = metricName;
          //                 }
        //
        //                 metric.MarkAsBuiltIn();
        //                 metric.AddOrUpdateChatMetadata(annotationResponse, annotationDuration);
        //
        //                 metric.Interpretation =
        //                     metric switch
        //                     {
          //                         BooleanMetric booleanMetric => booleanMetric.InterpretContentSafetyScore(),
          //                         NumericMetric numericMetric => numericMetric.InterpretContentSafetyScore(),
          //                         _ => metric.Interpretation
          //                     };
        //
        //                 if (diagnostics is not null)
        //                 {
          //                     metric.AddDiagnostics(diagnostics);
          //                 }
        //
        // #pragma warning disable S125 // Sections of code should not be commented out.
        //                 // The following commented code can be useful for debugging purposes.
        //                 // metric.LogJsonData(payload);
        //                 // metric.LogJsonData(annotationResult);
        // #pragma warning restore S125
        //
        //                 updatedResult.Metrics.Add(metric.Name, metric);
        //             }
      //
      //             return updatedResult;
      //         }
  }

  /// Filters the [EvaluationContext]s supplied by the caller via
  /// `additionalContext` down to just the [EvaluationContext]s that are
  /// relevant to the evaluation being performed by this
  /// [ContentSafetyEvaluator].
  ///
  /// Returns: The [EvaluationContext]s that are relevant to the evaluation
  /// being performed by this [ContentSafetyEvaluator].
  ///
  /// [additionalContext] The [EvaluationContext]s supplied by the caller.
  List<EvaluationContext>? filterAdditionalContext(Iterable<EvaluationContext>? additionalContext) {
    return null;
  }
}

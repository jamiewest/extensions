import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_message.dart';
import 'chat_configuration.dart';
import 'evaluation_context.dart';
import 'evaluation_result.dart';
import 'evaluator.dart';

/// An [Evaluator] that composes other [Evaluator]s to execute multiple
/// (concurrent) evaluations on a supplied response.
class CompositeEvaluator implements Evaluator {
  /// Initializes a new instance of the [CompositeEvaluator] class that composes
  /// the supplied [Evaluator]s.
  ///
  /// [evaluators] An array of [Evaluator]s that are to be composed.
  CompositeEvaluator({List<Evaluator>? evaluators = null});

  /// Gets the [Name]s of all the [EvaluationMetric]s produced by the composed
  /// [Evaluator]s.
  final ReadOnlyCollection<String> evaluationMetricNames;

  final List<Evaluator> _evaluators;

  /// Evaluates the supplied `modelResponse` and returns an [EvaluationResult]
  /// containing one or more [EvaluationMetric]s.
  ///
  /// Remarks: The [Name]s of the [EvaluationMetric]s contained in the returned
  /// [EvaluationResult] should match [EvaluationMetricNames]. Also note that
  /// `chatConfiguration` must not be omitted if one or more composed
  /// [Evaluator]s use an AI model to perform evaluation.
  ///
  /// Returns: An [EvaluationResult] containing one or more [EvaluationMetric]s.
  ///
  /// [messages] The conversation history including the request that produced
  /// the supplied `modelResponse`.
  ///
  /// [modelResponse] The response that is to be evaluated.
  ///
  /// [chatConfiguration] A [ChatConfiguration] that specifies the [ChatClient]
  /// that should be used if one or more composed [Evaluator]s use an AI model
  /// to perform evaluation.
  ///
  /// [additionalContext] Additional contextual information (beyond that which
  /// is available in `messages`) that composed [Evaluator]s may need to
  /// accurately evaluate the supplied `modelResponse`.
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the evaluation
  /// operation.
  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async {
    var metrics = List<EvaluationMetric>();
    var resultsStream = evaluateAndStreamResultsAsync(
      messages,
      modelResponse,
      chatConfiguration,
      additionalContext,
      cancellationToken,
    );
    for (final result in resultsStream.configureAwait(false)) {
      metrics.addRange(result.metrics.values);
    }
    return evaluationResult(metrics);
  }

  Stream<EvaluationResult> evaluateAndStreamResults(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) {
    /* TODO: unsupported node kind "unknown" */
    // async ValueTask<EvaluationResult> EvaluateAsync(IEvaluator e)
    //         {
    //             try
    //             {
    //                 return await e.EvaluateAsync(
    //                     messages,
    //                     modelResponse,
    //                     chatConfiguration,
    //                     additionalContext,
    //                     cancellationToken).ConfigureAwait(false);
    //             }
    //             catch (Exception ex)
    //             {
    //                 string message = ex.ToString();
    //                 var result = new EvaluationResult();
    //
    //                 if (e.EvaluationMetricNames.Count == 0)
    //                 {
    //                     throw new InvalidOperationException(
    //                         $"The '{nameof(e.EvaluationMetricNames)}' property on '{e.GetType().FullName}' returned an empty collection. An evaluator must advertise the names of the metrics that it supports.");
    //                 }
    //
    //                 foreach (string metricName in e.EvaluationMetricNames)
    //                 {
    //                     var metric = new EvaluationMetric(metricName);
    //                     metric.AddDiagnostics(EvaluationDiagnostic.Error(message));
    //                     result.Metrics.Add(metric.Name, metric);
    //                 }
    //
    //                 return result;
    //             }
    //         }
    var concurrentTasks = _evaluators.select(EvaluateAsync);
    return concurrentTasks.streamResultsAsync(
      cancellationToken: cancellationToken,
    );
  }
}

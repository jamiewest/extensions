import '../../abstractions/chat_completion/chat_message.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_diagnostic.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import '../numeric_metric.dart';
import '../utilities/timing_helper.dart';
import 'common/f1_algorithm.dart';
import 'common/simple_word_tokenizer.dart';
import 'f1_evaluator_context.dart';

/// An [Evaluator] that evaluates the quality of a response produced by an AI
/// model by comparing it to a reference response using the F1 scoring
/// algorithm. F1 score is the ratio of the number of shared words between the
/// generated response and the reference response.
///
/// Remarks: The [F1Evaluator] computes the F1 score of a response
/// ("hypothesis") in relation to a ground-truth reference supplied by
/// [GroundTruth]. The score is returned in a [NumericMetric] with a value
/// between 0.0 and 1.0 where 0.0 represents no match at all and 1.0 indicates
/// a perfect match. By default, the score is interpreted with a pass/fail
/// cutoff of 0.5. So a score of 0.5 or higher is passing and a score below
/// 0.5 is failing.
class F1Evaluator implements Evaluator {
  F1Evaluator();

  final ReadOnlyCollection<String> evaluationMetricNames = [F1MetricName];

  /// Gets the [Name] of the [NumericMetric] returned by [F1Evaluator].
  static String get f1MetricName {
    return "F1";
  }

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse,
    {ChatConfiguration? chatConfiguration, Iterable<EvaluationContext>? additionalContext, CancellationToken? cancellationToken, },
  ) {
    _ = Throw.ifNull(modelResponse);
    var metric = numericMetric(f1MetricName);
    var result = evaluationResult(metric);
    metric.markAsBuiltIn();
    if (string.isNullOrWhiteSpace(modelResponse.text)) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error('The ${nameof(modelResponse)} supplied for evaluation was null or empty.'));
      return Future<EvaluationResult>(result);
    }
    if (additionalContext?.ofType<F1EvaluatorContext>().firstOrDefault() is! F1EvaluatorContext context) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error(
                    'A value of type '${nameof(F1EvaluatorContext)}' was not found in the '${nameof(additionalContext)}' collection.'));
      return Future<EvaluationResult>(result);
    }
    (double score, TimeSpan duration) =
            TimingHelper.executeWithTiming(() =>
            {
                string[] reference = SimpleWordTokenizer.wordTokenize(context.groundTruth).toArray();
                string[] hypothesis = SimpleWordTokenizer.wordTokenize(modelResponse.text).toArray();
                double score = F1Algorithm.calculateF1Score(reference, hypothesis);
                return score;
            });
    metric.value = score;
    metric.addOrUpdateDurationMetadata(duration);
    metric.addOrUpdateContext(context);
    metric.interpretation = metric.interpret();
    return Future<EvaluationResult>(result);
  }
}

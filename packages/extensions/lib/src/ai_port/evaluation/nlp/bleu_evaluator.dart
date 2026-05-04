import '../../abstractions/chat_completion/chat_message.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_diagnostic.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import '../numeric_metric.dart';
import '../utilities/timing_helper.dart';
import 'bleu_evaluator_context.dart';
import 'common/bleu_algorithm.dart';
import 'common/simple_word_tokenizer.dart';
import 'common/smoothing_function.dart';

/// An [Evaluator] that evaluates the quality of a response produced by an AI
/// model by comparing it to a reference response using the BLEU (Bilingual
/// Evaluation Understudy) algorithm. It is often used to evaluate the quality
/// of machine translation or text generation tasks.
///
/// Remarks: The [BLEUEvaluator] computes the BLEU score of a response
/// ("hypothesis") compared to one or more reference responses supplied via
/// [References]. The score is returned in a [NumericMetric] with a value
/// between 0.0 and 1.0 where 0.0 represents no match at all and 1.0 indicates
/// a perfect match. By default, the score is interpreted with a pass/fail
/// cutoff of 0.5. So a score of 0.5 or higher is passing and a score below
/// 0.5 is failing.
class BLEUEvaluator implements Evaluator {
  BLEUEvaluator();

  final ReadOnlyCollection<String> evaluationMetricNames = [BLEUMetricName];

  /// Gets the [Name] of the [NumericMetric] returned by [BLEUEvaluator].
  static String get bleuMetricName {
    return "BLEU";
  }

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse,
    {ChatConfiguration? chatConfiguration, Iterable<EvaluationContext>? additionalContext, CancellationToken? cancellationToken, },
  ) {
    _ = Throw.ifNull(modelResponse);
    var metric = numericMetric(bleuMetricName);
    var result = evaluationResult(metric);
    metric.markAsBuiltIn();
    if (string.isNullOrWhiteSpace(modelResponse.text)) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error('The ${nameof(modelResponse)} supplied for evaluation was null or empty.'));
      return Future<EvaluationResult>(result);
    }
    if (additionalContext?.ofType<BLEUEvaluatorContext>().firstOrDefault() is! BLEUEvaluatorContext context) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error(
                    'A value of type '${nameof(BLEUEvaluatorContext)}' was not found in the '${nameof(additionalContext)}' collection.'));
      return Future<EvaluationResult>(result);
    }
    if (context.references.count is 0) {
      metric.addDiagnostics(
                EvaluationDiagnostic.error(
                    'Supplied '${nameof(BLEUEvaluatorContext)}' did not contain any '${nameof(BLEUEvaluatorContext.references)}'.'));
      return Future<EvaluationResult>(result);
    }
    (double score, TimeSpan duration) =
            TimingHelper.executeWithTiming(() =>
            {
                string[][] references =
                    context.references.select(
                        (reference) => SimpleWordTokenizer.wordTokenize(reference).toArray()).toArray();

                string[] hypothesis = SimpleWordTokenizer.wordTokenize(modelResponse.text).toArray();

                double score =
                    BLEUAlgorithm.sentenceBLEU(
                        references,
                        hypothesis,
                        BLEUAlgorithm.defaultBLEUWeights,
                        SmoothingFunction.method4);

                return score;
            });
    metric.value = score;
    metric.addOrUpdateDurationMetadata(duration);
    metric.addOrUpdateContext(context);
    metric.interpretation = metric.interpret();
    return Future<EvaluationResult>(result);
  }
}

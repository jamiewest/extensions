import 'package:extensions/annotations.dart';

import '../../../system/threading/cancellation_token.dart';
import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_diagnostic.dart';
import '../evaluation_metric_extensions.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import '../numeric_metric.dart';
import 'common/f1_algorithm.dart';
import 'common/simple_word_tokenizer.dart';
import 'f1_evaluator_context.dart';

/// Evaluates response quality using F1 scoring (shared word ratio).
///
/// Returns a [NumericMetric] named `"F1"` with a score between 0.0 and 1.0.
/// The default pass/fail threshold is 0.5.
///
/// Requires an [F1EvaluatorContext] in [additionalContext].
@Source(
  name: 'F1Evaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.NLP',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.NLP/',
)
class F1Evaluator implements Evaluator {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String f1MetricName = 'F1';

  @override
  List<String> get evaluationMetricNames => const [f1MetricName];

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async {
    final metric = NumericMetric(f1MetricName);
    final result = EvaluationResult.fromList([metric]);

    final responseText = modelResponse.text;
    if (responseText.isEmpty) {
      metric.addDiagnostic(EvaluationDiagnostic.error(
          'The modelResponse supplied for evaluation was null or empty.'));
      return result;
    }

    final ctx = additionalContext?.whereType<F1EvaluatorContext>().firstOrNull;
    if (ctx == null) {
      metric.addDiagnostic(EvaluationDiagnostic.error(
          'An F1EvaluatorContext was not found in additionalContext.'));
      return result;
    }

    final start = DateTime.now();
    final reference = SimpleWordTokenizer.wordTokenize(ctx.groundTruth);
    final hypothesis = SimpleWordTokenizer.wordTokenize(responseText);
    final score = F1Algorithm.calculateF1Score(reference, hypothesis);
    final duration = DateTime.now().difference(start);

    metric.value = score;
    metric.addOrUpdateDurationMetadata(duration);
    metric.addOrUpdateContext(ctx);
    metric.interpretation = metric.interpret();
    return result;
  }
}

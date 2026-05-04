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
import 'bleu_evaluator_context.dart';
import 'common/bleu_algorithm.dart';
import 'common/simple_word_tokenizer.dart';
import 'common/smoothing_function.dart';

/// Evaluates response quality using the BLEU (Bilingual Evaluation
/// Understudy) algorithm.
///
/// Returns a [NumericMetric] named `"BLEU"` with a score between 0.0 and 1.0.
/// The default pass/fail threshold is 0.5.
///
/// Requires a [BLEUEvaluatorContext] in [additionalContext].
@Source(
  name: 'BLEUEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.NLP',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.NLP/',
)
class BLEUEvaluator implements Evaluator {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String bleuMetricName = 'BLEU';

  @override
  List<String> get evaluationMetricNames => const [bleuMetricName];

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async {
    final metric = NumericMetric(bleuMetricName);
    final result = EvaluationResult.fromList([metric]);

    final responseText = modelResponse.text;
    if (responseText.isEmpty) {
      metric.addDiagnostic(EvaluationDiagnostic.error(
          'The modelResponse supplied for evaluation was null or empty.'));
      return result;
    }

    final ctx = additionalContext?.whereType<BLEUEvaluatorContext>().firstOrNull;
    if (ctx == null) {
      metric.addDiagnostic(EvaluationDiagnostic.error(
          'A BLEUEvaluatorContext was not found in additionalContext.'));
      return result;
    }
    if (ctx.references.isEmpty) {
      metric.addDiagnostic(EvaluationDiagnostic.error(
          'The supplied BLEUEvaluatorContext contained no references.'));
      return result;
    }

    final start = DateTime.now();
    final references = ctx.references
        .map((r) => SimpleWordTokenizer.wordTokenize(r))
        .toList();
    final hypothesis = SimpleWordTokenizer.wordTokenize(responseText);
    final score = BLEUAlgorithm.sentenceBLEU(
      references,
      hypothesis,
      weights: BLEUAlgorithm.defaultBLEUWeights,
      smoothingFunction: SmoothingFunction.method4,
    );
    final duration = DateTime.now().difference(start);

    metric.value = score;
    metric.addOrUpdateDurationMetadata(duration);
    metric.addOrUpdateContext(ctx);
    metric.interpretation = metric.interpret();
    return result;
  }
}

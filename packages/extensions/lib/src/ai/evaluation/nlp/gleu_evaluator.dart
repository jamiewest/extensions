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
import 'common/gleu_algorithm.dart';
import 'common/simple_word_tokenizer.dart';
import 'gleu_evaluator_context.dart';

/// Evaluates response quality using Google-BLEU (GLEU) n-gram overlap.
///
/// Returns a [NumericMetric] named `"GLEU"` with a score between 0.0 and 1.0.
/// The default pass/fail threshold is 0.5.
///
/// Requires a [GLEUEvaluatorContext] in [additionalContext].
@Source(
  name: 'GLEUEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.NLP',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.NLP/',
)
class GLEUEvaluator implements Evaluator {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String gleuMetricName = 'GLEU';

  @override
  List<String> get evaluationMetricNames => const [gleuMetricName];

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async {
    final metric = NumericMetric(gleuMetricName);
    final result = EvaluationResult.fromList([metric]);

    final responseText = modelResponse.text;
    if (responseText.isEmpty) {
      metric.addDiagnostic(EvaluationDiagnostic.error(
          'The modelResponse supplied for evaluation was null or empty.'));
      return result;
    }

    final ctx = additionalContext?.whereType<GLEUEvaluatorContext>().firstOrNull;
    if (ctx == null) {
      metric.addDiagnostic(EvaluationDiagnostic.error(
          'A GLEUEvaluatorContext was not found in additionalContext.'));
      return result;
    }
    if (ctx.references.isEmpty) {
      metric.addDiagnostic(EvaluationDiagnostic.error(
          'The supplied GLEUEvaluatorContext contained no references.'));
      return result;
    }

    final start = DateTime.now();
    final references = ctx.references
        .map((r) => SimpleWordTokenizer.wordTokenize(r))
        .toList();
    final hypothesis = SimpleWordTokenizer.wordTokenize(responseText);
    final score = GLEUAlgorithm.sentenceGLEU(references, hypothesis);
    final duration = DateTime.now().difference(start);

    metric.value = score;
    metric.addOrUpdateDurationMetadata(duration);
    metric.addOrUpdateContext(ctx);
    metric.interpretation = metric.interpret();
    return result;
  }
}

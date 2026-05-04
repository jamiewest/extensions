import '../evaluation_context.dart';
import 'bleu_evaluator.dart';

/// Contextual information that the [BLEUEvaluator] uses to compute the BLEU
/// score for a response.
///
/// Remarks: [BLEUEvaluator] measures the BLEU score of a response compared to
/// one or more reference responses supplied via [References]. BLEU (Bilingual
/// Evaluation Understudy) is a metric used to evaluate the quality of
/// machine-generated text.
class BLEUEvaluatorContext extends EvaluationContext {
  /// Initializes a new instance of the [BLEUEvaluatorContext] class.
  ///
  /// [references] The reference responses against which the response that is
  /// being evaluated is compared.
  BLEUEvaluatorContext({Iterable<String>? references = null});

  /// Gets the references against which the provided response will be scored.
  ///
  /// Remarks: The [BLEUEvaluator] measures the degree to which the response
  /// being evaluated is similar to the responses supplied via [References]. The
  /// metric will be reported as a BLEU score.
  final List<String> references;

  /// Gets the unique [Name] that is used for [BLEUEvaluatorContext].
  static String get referencesContextName {
    return "references(BLEU)";
  }
}

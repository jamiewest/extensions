import '../evaluation_context.dart';
import 'gleu_evaluator.dart';

/// Contextual information that the [GLEUEvaluator] uses to compute the GLEU
/// score for a response.
///
/// Remarks: [GLEUEvaluator] measures the GLEU score of a response compared to
/// one or more reference responses supplied via [References]. GLEU
/// (Google-BLEU) is a metric used to evaluate the quality of
/// machine-generated text.
class GLEUEvaluatorContext extends EvaluationContext {
  /// Initializes a new instance of the [GLEUEvaluatorContext] class.
  ///
  /// [references] The reference responses against which the response that is
  /// being evaluated is compared.
  GLEUEvaluatorContext({Iterable<String>? references = null});

  /// Gets the references against which the provided response will be scored.
  ///
  /// Remarks: The [GLEUEvaluator] measures the degree to which the response
  /// being evaluated is similar to the responses supplied via [References]. The
  /// metric will be reported as a GLEU score.
  final List<String> references;

  /// Gets the unique [Name] that is used for [GLEUEvaluatorContext].
  static String get referencesContextName {
    return "references(GLEU)";
  }
}

import '../evaluation_context.dart';
import 'f1_evaluator.dart';

/// Contextual information that the [F1Evaluator] uses to compute the F1 score
/// for a response.
///
/// Remarks: [F1Evaluator] measures the F1 score of a response compared to a
/// reference response that is supplied via [GroundTruth]. F1 is a metric used
/// to valuate the quality of machine-generated text. It is the ratio of the
/// number of shared words between the generated response and the reference
/// response.
class F1EvaluatorContext extends EvaluationContext {
  /// Initializes a new instance of the [F1EvaluatorContext] class.
  ///
  /// [groundTruth] The reference response against which the provided response
  /// will be scored.
  const F1EvaluatorContext(String groundTruth) : groundTruth = groundTruth;

  /// Gets the reference response against which the provided response will be
  /// scored.
  ///
  /// Remarks: The [F1Evaluator] measures the degree to which the response being
  /// evaluated is similar to the response supplied via [GroundTruth]. The
  /// metric will be reported as an F1 score.
  final String groundTruth;

  /// Gets the unique [Name] that is used for [F1EvaluatorContext].
  static String get groundTruthContextName {
    return "Ground truth(F1)";
  }
}

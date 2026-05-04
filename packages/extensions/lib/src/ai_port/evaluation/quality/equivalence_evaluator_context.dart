import '../evaluation_context.dart';
import 'equivalence_evaluator.dart';

/// Contextual information that the [EquivalenceEvaluator] uses to evaluate
/// the 'Equivalence' of a response.
///
/// Remarks: [EquivalenceEvaluator] measures the degree to which the response
/// being evaluated is similar to the response supplied via `groundTruth`.
///
/// [groundTruth] The ground truth response against which the response that is
/// being evaluated is compared.
class EquivalenceEvaluatorContext extends EvaluationContext {
  /// Contextual information that the [EquivalenceEvaluator] uses to evaluate
  /// the 'Equivalence' of a response.
  ///
  /// Remarks: [EquivalenceEvaluator] measures the degree to which the response
  /// being evaluated is similar to the response supplied via `groundTruth`.
  ///
  /// [groundTruth] The ground truth response against which the response that is
  /// being evaluated is compared.
  const EquivalenceEvaluatorContext(String groundTruth)
    : groundTruth = groundTruth;

  /// Gets the ground truth response against which the response that is being
  /// evaluated is compared.
  ///
  /// Remarks: The [EquivalenceEvaluator] measures the degree to which the
  /// response being evaluated is similar to the response supplied via
  /// [GroundTruth].
  final String groundTruth = groundTruth;

  /// Gets the unique [Name] that is used for [EquivalenceEvaluatorContext].
  static String get groundTruthContextName {
    return "Ground truth(Equivalence)";
  }
}

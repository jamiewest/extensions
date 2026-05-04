import '../evaluation_context.dart';
import 'completeness_evaluator.dart';

/// Contextual information that the [CompletenessEvaluator] uses to evaluate
/// the 'Completeness' of a response.
///
/// Remarks: [CompletenessEvaluator] measures an AI system's ability to
/// deliver comprehensive and accurate responses. It assesses how thoroughly
/// the response aligns with the key information, claims, and statements
/// established in the supplied `groundTruth`.
///
/// [groundTruth] The ground truth against which the response that is being
/// evaluated is assessed.
class CompletenessEvaluatorContext extends EvaluationContext {
  /// Contextual information that the [CompletenessEvaluator] uses to evaluate
  /// the 'Completeness' of a response.
  ///
  /// Remarks: [CompletenessEvaluator] measures an AI system's ability to
  /// deliver comprehensive and accurate responses. It assesses how thoroughly
  /// the response aligns with the key information, claims, and statements
  /// established in the supplied `groundTruth`.
  ///
  /// [groundTruth] The ground truth against which the response that is being
  /// evaluated is assessed.
  const CompletenessEvaluatorContext(String groundTruth)
    : groundTruth = groundTruth;

  /// Gets the ground truth against which the response that is being evaluated
  /// is assessed.
  ///
  /// Remarks: [CompletenessEvaluator] measures an AI system's ability to
  /// deliver comprehensive and accurate responses. It assesses how thoroughly
  /// the response aligns with the key information, claims, and statements
  /// established in the supplied [GroundTruth].
  final String groundTruth = groundTruth;

  /// Gets the unique [Name] that is used for [CompletenessEvaluatorContext].
  static String get groundTruthContextName {
    return "Ground truth(Completeness)";
  }
}

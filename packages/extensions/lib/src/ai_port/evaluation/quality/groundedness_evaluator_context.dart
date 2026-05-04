import '../evaluation_context.dart';
import 'groundedness_evaluator.dart';

/// Contextual information that the [GroundednessEvaluator] uses to evaluate
/// the 'Groundedness' of a response.
///
/// Remarks: [GroundednessEvaluator] measures the degree to which the response
/// being evaluated is grounded in the information present in the supplied
/// `groundingContext`.
///
/// [groundingContext] Contextual information against which the 'Groundedness'
/// of a response is evaluated.
class GroundednessEvaluatorContext extends EvaluationContext {
  /// Contextual information that the [GroundednessEvaluator] uses to evaluate
  /// the 'Groundedness' of a response.
  ///
  /// Remarks: [GroundednessEvaluator] measures the degree to which the response
  /// being evaluated is grounded in the information present in the supplied
  /// `groundingContext`.
  ///
  /// [groundingContext] Contextual information against which the 'Groundedness'
  /// of a response is evaluated.
  const GroundednessEvaluatorContext(String groundingContext)
    : groundingContext = groundingContext;

  /// Gets the contextual information against which the 'Groundedness' of a
  /// response is evaluated.
  ///
  /// Remarks: The [GroundednessEvaluator] measures the degree to which the
  /// response being evaluated is grounded in the information present in the
  /// supplied [GroundingContext].
  final String groundingContext = groundingContext;

  /// Gets the unique [Name] that is used for [GroundednessEvaluatorContext].
  static String get groundingContextName {
    return "Grounding context(Groundedness)";
  }
}

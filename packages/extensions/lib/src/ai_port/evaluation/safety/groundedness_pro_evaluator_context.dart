import '../evaluation_context.dart';
import 'groundedness_pro_evaluator.dart';

/// Contextual information that the [GroundednessProEvaluator] uses to
/// evaluate the groundedness of a response.
///
/// Remarks: [GroundednessProEvaluator] measures the degree to which the
/// response being evaluated is grounded in the information present in the
/// supplied `groundingContext`.
///
/// [groundingContext] Contextual information against which the groundedness
/// of a response is evaluated.
class GroundednessProEvaluatorContext extends EvaluationContext {
  /// Contextual information that the [GroundednessProEvaluator] uses to
  /// evaluate the groundedness of a response.
  ///
  /// Remarks: [GroundednessProEvaluator] measures the degree to which the
  /// response being evaluated is grounded in the information present in the
  /// supplied `groundingContext`.
  ///
  /// [groundingContext] Contextual information against which the groundedness
  /// of a response is evaluated.
  const GroundednessProEvaluatorContext(String groundingContext)
    : groundingContext = groundingContext;

  /// Gets the contextual information against which the groundedness of a
  /// response is evaluated.
  ///
  /// Remarks: The [GroundednessProEvaluator] measures the degree to which the
  /// response being evaluated is grounded in the information present in the
  /// supplied [GroundingContext].
  final String groundingContext = groundingContext;

  /// Gets the unique [Name] that is used for [GroundednessProEvaluatorContext].
  static String get groundingContextName {
    return "Grounding context(Groundedness Pro)";
  }
}

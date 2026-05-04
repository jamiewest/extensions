import '../evaluation_context.dart';
import 'ungrounded_attributes_evaluator.dart';

/// Contextual information that the [UngroundedAttributesEvaluator] uses to
/// evaluate whether a response is ungrounded.
///
/// Remarks: [UngroundedAttributesEvaluator] measures whether the response
/// being evaluated is first, ungrounded based on the information present in
/// the supplied `groundingContext`. It then checks whether the response
/// contains information about the protected class or emotional state of a
/// person.
///
/// [groundingContext] Contextual information against which the groundedness
/// (or ungroundedness) of a response is evaluated.
class UngroundedAttributesEvaluatorContext extends EvaluationContext {
  /// Contextual information that the [UngroundedAttributesEvaluator] uses to
  /// evaluate whether a response is ungrounded.
  ///
  /// Remarks: [UngroundedAttributesEvaluator] measures whether the response
  /// being evaluated is first, ungrounded based on the information present in
  /// the supplied `groundingContext`. It then checks whether the response
  /// contains information about the protected class or emotional state of a
  /// person.
  ///
  /// [groundingContext] Contextual information against which the groundedness
  /// (or ungroundedness) of a response is evaluated.
  const UngroundedAttributesEvaluatorContext(String groundingContext)
    : groundingContext = groundingContext;

  /// Gets the contextual information against which the groundedness (or
  /// ungroundedness) of a response is evaluated.
  ///
  /// Remarks: The [UngroundedAttributesEvaluator] measures whether the response
  /// being evaluated is first, ungrounded based on the information present in
  /// the supplied [GroundingContext]. It then checks whether the response
  /// contains information about the protected class or emotional state of a
  /// person.
  final String groundingContext = groundingContext;

  /// Gets the unique [Name] that is used for
  /// [UngroundedAttributesEvaluatorContext].
  static String get groundingContextName {
    return "Grounding context(Ungrounded Attributes)";
  }
}

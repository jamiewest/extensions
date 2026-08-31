import '../../text_content.dart';
import '../evaluation_context.dart';

/// Context for [GroundednessProEvaluator]: the grounding information against
/// which response fidelity is assessed.
class GroundednessProEvaluatorContext extends EvaluationContext {
  /// Creates a [GroundednessProEvaluatorContext] from [groundingContext].
  GroundednessProEvaluatorContext(this.groundingContext)
    : super(groundingContextName, contents: [TextContent(groundingContext)]);

  /// Unique context name used when recording contexts on metrics.
  static const String groundingContextName =
      'Grounding context(Groundedness Pro)';

  /// The reference context used to assess groundedness.
  final String groundingContext;
}

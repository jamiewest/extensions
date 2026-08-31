import '../../text_content.dart';
import '../evaluation_context.dart';

/// Context for [GroundednessEvaluator]: the grounding information against
/// which fidelity is measured.
class GroundednessEvaluatorContext extends EvaluationContext {
  /// Creates a [GroundednessEvaluatorContext] from [groundingContext].
  GroundednessEvaluatorContext(this.groundingContext)
    : super(groundingContextName, contents: [TextContent(groundingContext)]);

  /// Unique context name used when recording contexts on metrics.
  static const String groundingContextName = 'Grounding context(Groundedness)';

  /// The source material the response should be grounded in.
  final String groundingContext;
}

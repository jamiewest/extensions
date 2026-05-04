import 'package:extensions/annotations.dart';

import '../../text_content.dart';
import '../evaluation_context.dart';

/// Context for [GroundednessProEvaluator]: the grounding information against
/// which response fidelity is assessed.
@Source(
  name: 'GroundednessProEvaluatorContext.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Safety',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Safety/',
)
class GroundednessProEvaluatorContext extends EvaluationContext {
  /// Creates a [GroundednessProEvaluatorContext] from [groundingContext].
  GroundednessProEvaluatorContext(this.groundingContext)
      : super(groundingContextName,
            contents: [TextContent(groundingContext)]);

  /// Unique context name used when recording contexts on metrics.
  static const String groundingContextName =
      'Grounding context(Groundedness Pro)';

  /// The reference context used to assess groundedness.
  final String groundingContext;
}

import 'package:extensions/annotations.dart';

import '../../text_content.dart';
import '../evaluation_context.dart';

/// Context for [GroundednessEvaluator]: the grounding information against
/// which fidelity is measured.
@Source(
  name: 'GroundednessEvaluatorContext.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class GroundednessEvaluatorContext extends EvaluationContext {
  /// Creates a [GroundednessEvaluatorContext] from [groundingContext].
  GroundednessEvaluatorContext(this.groundingContext)
      : super(groundingContextName, contents: [TextContent(groundingContext)]);

  /// Unique context name used when recording contexts on metrics.
  static const String groundingContextName = 'Grounding context(Groundedness)';

  /// The source material the response should be grounded in.
  final String groundingContext;
}

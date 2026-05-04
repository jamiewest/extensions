import 'package:extensions/annotations.dart';

import '../../text_content.dart';
import '../evaluation_context.dart';

/// Context for [EquivalenceEvaluator]: the expected ground-truth response.
@Source(
  name: 'EquivalenceEvaluatorContext.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class EquivalenceEvaluatorContext extends EvaluationContext {
  /// Creates an [EquivalenceEvaluatorContext] from [groundTruth].
  EquivalenceEvaluatorContext(this.groundTruth)
      : super(groundTruthContextName, contents: [TextContent(groundTruth)]);

  /// Unique context name used when recording contexts on metrics.
  static const String groundTruthContextName = 'Ground truth(Equivalence)';

  /// The reference response to compare semantic equivalence against.
  final String groundTruth;
}

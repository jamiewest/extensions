import 'package:extensions/annotations.dart';

import '../../text_content.dart';
import '../evaluation_context.dart';

/// Contextual information for [F1Evaluator]: a single ground-truth reference
/// response.
@Source(
  name: 'F1EvaluatorContext.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.NLP',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.NLP/',
)
class F1EvaluatorContext extends EvaluationContext {
  /// Creates an [F1EvaluatorContext] from [groundTruth].
  F1EvaluatorContext(this.groundTruth)
      : super(groundTruthContextName, contents: [TextContent(groundTruth)]);

  /// Unique context name used when recording contexts on metrics.
  static const String groundTruthContextName = 'Ground truth(F1)';

  /// The reference response to compare against.
  final String groundTruth;
}

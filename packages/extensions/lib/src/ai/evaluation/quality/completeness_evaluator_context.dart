import '../../text_content.dart';
import '../evaluation_context.dart';

/// Context for [CompletenessEvaluator]: the ground truth response against
/// which completeness is measured.
class CompletenessEvaluatorContext extends EvaluationContext {
  /// Creates a [CompletenessEvaluatorContext] from [groundTruth].
  CompletenessEvaluatorContext(this.groundTruth)
    : super(groundTruthContextName, contents: [TextContent(groundTruth)]);

  /// Unique context name used when recording contexts on metrics.
  static const String groundTruthContextName = 'Ground truth(Completeness)';

  /// The reference response that contains all expected information.
  final String groundTruth;
}

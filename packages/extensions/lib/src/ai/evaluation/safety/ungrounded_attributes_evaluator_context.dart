import 'package:extensions/annotations.dart';

import '../../text_content.dart';
import '../evaluation_context.dart';

/// Context for [UngroundedAttributesEvaluator]: the grounding information
/// used to assess whether the response contains ungrounded attributes.
@Source(
  name: 'UngroundedAttributesEvaluatorContext.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Safety',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Safety/',
)
class UngroundedAttributesEvaluatorContext extends EvaluationContext {
  /// Creates an [UngroundedAttributesEvaluatorContext] from [groundingContext].
  UngroundedAttributesEvaluatorContext(this.groundingContext)
      : super(groundingContextName,
            contents: [TextContent(groundingContext)]);

  /// Unique context name used when recording contexts on metrics.
  static const String groundingContextName =
      'Grounding context(Ungrounded Attributes)';

  /// The reference context against which ungrounded attributes are assessed.
  final String groundingContext;
}

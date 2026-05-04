import 'package:extensions/annotations.dart';

import 'content_safety_evaluator.dart';

/// Evaluates AI responses for ungrounded protected-class attributes or
/// emotional state inferences.
///
/// Returns a [NumericMetric] named `"UngroundedAttributes"` scored 0–7
/// (fail above 0). Requires an [UngroundedAttributesEvaluatorContext].
@Source(
  name: 'UngroundedAttributesEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Safety',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Safety/',
)
class UngroundedAttributesEvaluator extends ContentSafetyEvaluator {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String ungroundedAttributesMetricName = 'UngroundedAttributes';

  /// Creates an [UngroundedAttributesEvaluator].
  UngroundedAttributesEvaluator({required super.configuration})
      : super(
          annotationTask: 'ungrounded attributes',
          metricNames: const {
            'ungrounded_attributes': ungroundedAttributesMetricName,
          },
        );
}

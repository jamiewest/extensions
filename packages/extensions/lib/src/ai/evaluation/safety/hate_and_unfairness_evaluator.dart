import 'package:extensions/annotations.dart';

import 'content_safety_evaluator.dart';

/// Evaluates AI responses for hate speech and unfairness.
///
/// Returns a [NumericMetric] named `"HateAndUnfairness"` with a severity
/// score 0–7 (fail above 0).
@Source(
  name: 'HateAndUnfairnessEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Safety',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Safety/',
)
class HateAndUnfairnessEvaluator extends ContentSafetyEvaluator {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String hateAndUnfairnessMetricName = 'HateAndUnfairness';

  /// Creates a [HateAndUnfairnessEvaluator].
  HateAndUnfairnessEvaluator({required super.configuration})
      : super(
          annotationTask: 'content harm',
          metricNames: const {
            'hate_unfairness': hateAndUnfairnessMetricName,
          },
        );
}

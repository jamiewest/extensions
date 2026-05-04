import 'package:extensions/annotations.dart';

import 'content_safety_evaluator.dart';

/// Evaluates AI responses for self-harm advocacy.
///
/// Returns a [NumericMetric] named `"SelfHarm"` with a severity score 0–7
/// (fail above 0).
@Source(
  name: 'SelfHarmEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Safety',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Safety/',
)
class SelfHarmEvaluator extends ContentSafetyEvaluator {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String selfHarmMetricName = 'SelfHarm';

  /// Creates a [SelfHarmEvaluator].
  SelfHarmEvaluator({required super.configuration})
      : super(
          annotationTask: 'content harm',
          metricNames: const {'self_harm': selfHarmMetricName},
        );
}

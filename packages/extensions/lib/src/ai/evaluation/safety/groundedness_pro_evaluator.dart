import 'package:extensions/annotations.dart';

import 'content_safety_evaluator.dart';

/// Enterprise-grade groundedness evaluator using the Azure AI Foundry service.
///
/// Returns a [NumericMetric] named `"Groundedness"` scored 0–7 (fail above 0).
/// Requires a [GroundednessProEvaluatorContext].
@Source(
  name: 'GroundednessProEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Safety',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Safety/',
)
class GroundednessProEvaluator extends ContentSafetyEvaluator {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String groundednessMetricName = 'Groundedness';

  /// Creates a [GroundednessProEvaluator].
  GroundednessProEvaluator({required super.configuration})
      : super(
          annotationTask: 'groundedness',
          metricNames: const {
            'groundedness': groundednessMetricName,
          },
        );
}

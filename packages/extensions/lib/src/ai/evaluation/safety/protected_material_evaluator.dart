import 'package:extensions/annotations.dart';

import 'content_safety_evaluator.dart';

/// Evaluates AI responses for copyrighted or otherwise protected material.
///
/// Returns a [NumericMetric] named `"ProtectedMaterial"` scored 0–7
/// (fail above 0).
@Source(
  name: 'ProtectedMaterialEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Safety',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Safety/',
)
class ProtectedMaterialEvaluator extends ContentSafetyEvaluator {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String protectedMaterialMetricName = 'ProtectedMaterial';

  /// Creates a [ProtectedMaterialEvaluator].
  ProtectedMaterialEvaluator({required super.configuration})
      : super(
          annotationTask: 'protected material',
          metricNames: const {
            'protected_material': protectedMaterialMetricName,
          },
        );
}

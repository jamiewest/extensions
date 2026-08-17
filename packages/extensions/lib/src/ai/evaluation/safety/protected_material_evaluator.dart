import 'content_safety_evaluator.dart';

/// Evaluates AI responses for copyrighted or otherwise protected material.
///
/// Returns a [NumericMetric] named `"ProtectedMaterial"` scored 0–7
/// (fail above 0).
class ProtectedMaterialEvaluator extends ContentSafetyEvaluator {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String protectedMaterialMetricName = 'ProtectedMaterial';

  /// Creates a [ProtectedMaterialEvaluator].
  ProtectedMaterialEvaluator({required super.configuration})
    : super(
        annotationTask: 'protected material',
        metricNames: const {'protected_material': protectedMaterialMetricName},
      );
}

import 'content_safety_evaluator.dart';

/// Evaluates AI responses for sexual content.
///
/// Returns a [NumericMetric] named `"Sexual"` with a severity score 0–7
/// (fail above 0).
class SexualEvaluator extends ContentSafetyEvaluator {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String sexualMetricName = 'Sexual';

  /// Creates a [SexualEvaluator].
  SexualEvaluator({required super.configuration})
    : super(
        annotationTask: 'content harm',
        metricNames: const {'sexual': sexualMetricName},
      );
}

import 'content_safety_evaluator.dart';

/// Evaluates AI responses for violent content.
///
/// Returns a [NumericMetric] named `"Violence"` with a severity score 0–7
/// (fail above 0).
class ViolenceEvaluator extends ContentSafetyEvaluator {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String violenceMetricName = 'Violence';

  /// Creates a [ViolenceEvaluator].
  ViolenceEvaluator({required super.configuration})
    : super(
        annotationTask: 'content harm',
        metricNames: const {'violence': violenceMetricName},
      );
}

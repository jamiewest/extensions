import 'evaluation_metric.dart';

/// An [EvaluationMetric] with a numeric value.
///
/// Commonly used for scores in a defined range, such as 0.0–1.0 or 1–5.
class NumericMetric extends EvaluationMetric {
  /// Creates a [NumericMetric] with the given [name], optional [value], and
  /// optional [reason].
  NumericMetric(super.name, {this.value, super.reason});

  /// The numeric value of this metric.
  double? value;
}

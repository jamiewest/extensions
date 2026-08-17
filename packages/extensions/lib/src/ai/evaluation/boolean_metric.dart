import 'evaluation_metric.dart';

/// An [EvaluationMetric] with a boolean value (pass/fail or yes/no).
class BooleanMetric extends EvaluationMetric {
  /// Creates a [BooleanMetric] with the given [name], optional [value], and
  /// optional [reason].
  BooleanMetric(super.name, {this.value, super.reason});

  /// The boolean value of this metric.
  bool? value;
}

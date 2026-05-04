/// An base class that represents the result of an evaluation containing a
/// value of type `T`.
///
/// [T] The type of the [Value].
class EvaluationMetric<T> extends EvaluationMetric {
  /// Initializes a new instance of the [EvaluationMetric] class.
  ///
  /// [name] The name of the [EvaluationMetric].
  ///
  /// [value] The value of the [EvaluationMetric].
  ///
  /// [reason] An optional string that can be used to provide some commentary
  /// around the result represented by this [EvaluationMetric].
  EvaluationMetric(String name, T? value, {String? reason = null})
    : value = value;

  /// Gets or sets the value of the [EvaluationMetric].
  T? value;
}

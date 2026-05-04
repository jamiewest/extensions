/// An [EvaluationMetric] containing a [Boolean] value that can be used to
/// represent an outcome that can have one of two possible values (such as yes
/// v/s no, or pass v/s fail).
///
/// [name] The name of the [BooleanMetric].
///
/// [value] The value of the [BooleanMetric].
///
/// [reason] An optional string that can be used to provide some commentary
/// around the result represented by this [BooleanMetric].
class BooleanMetric extends EvaluationMetric<bool?> {
  /// An [EvaluationMetric] containing a [Boolean] value that can be used to
  /// represent an outcome that can have one of two possible values (such as yes
  /// v/s no, or pass v/s fail).
  ///
  /// [name] The name of the [BooleanMetric].
  ///
  /// [value] The value of the [BooleanMetric].
  ///
  /// [reason] An optional string that can be used to provide some commentary
  /// around the result represented by this [BooleanMetric].
  BooleanMetric(String name, {bool? value = null, String? reason = null});
}

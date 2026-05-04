/// An [EvaluationMetric] containing a [String] value.
///
/// Remarks: A common use case for [StringMetric] is to represent a single
/// value in an enumeration (or to represent one value out of a set of
/// possible values).
///
/// [name] The name of the [StringMetric].
///
/// [value] The value of the [StringMetric].
///
/// [reason] An optional string that can be used to provide some commentary
/// around the result represented by this [StringMetric].
class StringMetric extends EvaluationMetric<String> {
  /// An [EvaluationMetric] containing a [String] value.
  ///
  /// Remarks: A common use case for [StringMetric] is to represent a single
  /// value in an enumeration (or to represent one value out of a set of
  /// possible values).
  ///
  /// [name] The name of the [StringMetric].
  ///
  /// [value] The value of the [StringMetric].
  ///
  /// [reason] An optional string that can be used to provide some commentary
  /// around the result represented by this [StringMetric].
  StringMetric(String name, {String? value = null, String? reason = null});
}

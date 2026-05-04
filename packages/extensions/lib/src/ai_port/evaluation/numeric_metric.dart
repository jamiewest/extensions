/// An [EvaluationMetric] containing a numeric value.
///
/// Remarks: [NumericMetric] can be used to represent any numeric value. The
/// underlying type of a [NumericMetric]'s value is `double`. However, it can
/// be used to represent any type of numeric value including `int`, `long`,
/// `float` etc. A common use case for [NumericMetric] is to represent numeric
/// scores that fall within a well defined range. For example, it can be used
/// to represent a score between 1 and 5, where 1 is considered a poor score,
/// and 5 is considered an excellent score.
///
/// [name] The name of the [NumericMetric].
///
/// [value] The value of the [NumericMetric].
///
/// [reason] An optional string that can be used to provide some commentary
/// around the result represented by this [NumericMetric].
class NumericMetric extends EvaluationMetric<double?> {
  /// An [EvaluationMetric] containing a numeric value.
  ///
  /// Remarks: [NumericMetric] can be used to represent any numeric value. The
  /// underlying type of a [NumericMetric]'s value is `double`. However, it can
  /// be used to represent any type of numeric value including `int`, `long`,
  /// `float` etc. A common use case for [NumericMetric] is to represent numeric
  /// scores that fall within a well defined range. For example, it can be used
  /// to represent a score between 1 and 5, where 1 is considered a poor score,
  /// and 5 is considered an excellent score.
  ///
  /// [name] The name of the [NumericMetric].
  ///
  /// [value] The value of the [NumericMetric].
  ///
  /// [reason] An optional string that can be used to provide some commentary
  /// around the result represented by this [NumericMetric].
  NumericMetric(String name, {double? value = null, String? reason = null});
}

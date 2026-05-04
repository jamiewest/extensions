/// An enumeration that identifies the set of possible ways in which an
/// [EvaluationMetric] can be interpreted.
enum EvaluationRating {
  /// A value that indicates that the [Value] is unknown.
  unknown,

  /// A value that indicates that the [Value] cannot be interpreted
  /// conclusively.
  inconclusive,

  /// A value that indicates that the [Value] is interpreted as being
  /// unacceptable.
  unacceptable,

  /// A value that indicates that the [Value] is interpreted as being poor.
  poor,

  /// A value that indicates that the [Value] is interpreted as being average.
  average,

  /// A value that indicates that the [Value] is interpreted as being good.
  good,

  /// A value that indicates that the [Value] is interpreted as being
  /// exceptional.
  exceptional,
}

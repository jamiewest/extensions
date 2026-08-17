/// Identifies how the result of an evaluation should be interpreted.
enum EvaluationRating {
  /// The rating cannot be determined.
  unknown,

  /// The result cannot be interpreted conclusively.
  inconclusive,

  /// The result is considered unacceptable.
  unacceptable,

  /// The result is considered poor.
  poor,

  /// The result is considered average.
  average,

  /// The result is considered good.
  good,

  /// The result is considered exceptional.
  exceptional,
}

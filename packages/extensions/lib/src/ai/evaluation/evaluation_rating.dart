import 'package:extensions/annotations.dart';

/// Identifies how the result of an evaluation should be interpreted.
@Source(
  name: 'EvaluationRating.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation/',
)
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

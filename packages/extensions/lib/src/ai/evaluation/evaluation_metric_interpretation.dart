import 'package:extensions/annotations.dart';

import 'evaluation_rating.dart';

/// Specifies how an [EvaluationMetric]'s result should be interpreted.
@Source(
  name: 'EvaluationMetricInterpretation.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation/',
)
class EvaluationMetricInterpretation {
  /// Creates an [EvaluationMetricInterpretation].
  EvaluationMetricInterpretation({
    this.rating = EvaluationRating.unknown,
    this.failed = false,
    this.reason,
  });

  /// How good or bad the result is considered.
  EvaluationRating rating;

  /// Whether the result is considered a failure.
  bool failed;

  /// Optional commentary on the rating or failure.
  String? reason;
}

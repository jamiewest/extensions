import 'evaluation_rating.dart';

/// Specifies how an [EvaluationMetric]'s result should be interpreted.
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

import 'evaluation_rating.dart';

/// Specifies how the result represented in an associated [EvaluationMetric]
/// should be interpreted.
///
/// [rating] An [EvaluationRating] that identifies how good or bad the result
/// represented in the associated [EvaluationMetric] is considered.
///
/// [failed] `true` if the result represented in the associated
/// [EvaluationMetric] is considered a failure; `false` otherwise.
///
/// [reason] An optional string that can be used to provide some commentary
/// around the values specified for `rating` and / or `failed`.
class EvaluationMetricInterpretation {
  /// Specifies how the result represented in an associated [EvaluationMetric]
  /// should be interpreted.
  ///
  /// [rating] An [EvaluationRating] that identifies how good or bad the result
  /// represented in the associated [EvaluationMetric] is considered.
  ///
  /// [failed] `true` if the result represented in the associated
  /// [EvaluationMetric] is considered a failure; `false` otherwise.
  ///
  /// [reason] An optional string that can be used to provide some commentary
  /// around the values specified for `rating` and / or `failed`.
  EvaluationMetricInterpretation({
    EvaluationRating? rating = null,
    bool? failed = null,
    String? reason = null,
  });

  /// Gets or sets an [EvaluationRating] that identifies how good or bad the
  /// result represented in the associated [EvaluationMetric] is considered.
  EvaluationRating rating = rating;

  /// Gets or sets a value indicating whether the result represented in the
  /// associated [EvaluationMetric] is considered a failure.
  bool failed = failed;

  /// Gets or sets a string that can optionally be used to provide some
  /// commentary around the values specified for [Rating] and / or [Failed].
  String? reason = reason;
}

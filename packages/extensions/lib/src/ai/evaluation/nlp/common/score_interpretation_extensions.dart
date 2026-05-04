import '../../evaluation_metric_extensions.dart';
import '../../evaluation_metric_interpretation.dart';
import '../../numeric_metric.dart';

/// Convenience re-export and aliases for NLP score interpretation.
///
/// Use [NumericMetricInterpretationExtensions.interpret] directly for
/// 0–1 NLP scores.
extension NlpScoreInterpretationExtensions on NumericMetric {
  /// Interprets this metric's value as a 0.0–1.0 NLP score.
  ///
  /// Delegates to [NumericMetricInterpretationExtensions.interpret].
  EvaluationMetricInterpretation interpretNlpScore() => interpret();
}

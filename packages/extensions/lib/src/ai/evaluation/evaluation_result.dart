import 'package:extensions/annotations.dart';

import 'evaluation_metric.dart';

/// A collection of [EvaluationMetric]s representing the result of an
/// evaluation run.
@Source(
  name: 'EvaluationResult.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation/',
)
class EvaluationResult {
  /// Creates an [EvaluationResult] with the given [metrics] map, or an empty
  /// map if [metrics] is null.
  EvaluationResult({Map<String, EvaluationMetric>? metrics})
      : metrics = metrics ?? {};

  /// Creates an [EvaluationResult] from a flat list of metrics (keyed by
  /// [EvaluationMetric.name]).
  factory EvaluationResult.fromList(Iterable<EvaluationMetric> metrics) {
    return EvaluationResult(
      metrics: {for (final m in metrics) m.name: m},
    );
  }

  /// Metrics keyed by [EvaluationMetric.name].
  final Map<String, EvaluationMetric> metrics;

  /// Returns the metric named [metricName] cast to [T], or null if not found.
  ///
  /// The first element of the record is `true` when a match was found.
  (bool, T?) tryGet<T extends EvaluationMetric>(String metricName) {
    final m = metrics[metricName];
    if (m is T) return (true, m);
    return (false, null);
  }

  /// Returns the metric named [metricName] cast to [T].
  ///
  /// Throws [StateError] if not found or wrong type.
  T getValue<T extends EvaluationMetric>(String metricName) {
    final m = metrics[metricName];
    if (m is T) return m;
    throw StateError(
        "Metric '$metricName' of type $T was not found in the result.");
  }
}

/// A collection of one or more [EvaluationMetric]s that represent the result
/// of an evaluation.
class EvaluationResult {
  /// Initializes a new instance of the [EvaluationResult] class.
  ///
  /// [metrics] A dictionary containing one or more [EvaluationMetric]s that
  /// represent the result of an evaluation. The dictionary is keyed on the
  /// [Name]s of the contained [EvaluationMetric]s.
  EvaluationResult({Map<String, EvaluationMetric>? metrics = null}) : metrics = metrics;

  /// Gets or sets a collection of one or more [EvaluationMetric]s that
  /// represent the result of an evaluation.
  Map<String, EvaluationMetric> metrics;

  /// Returns an [EvaluationMetric] with type `T` and with the [Name] specified
  /// via `metricName` if it exists in [Metrics].
  ///
  /// Returns: `true` if a matching `value` exists in [Metrics]; `false`
  /// otherwise.
  ///
  /// [metricName] The [Name] of the [EvaluationMetric] to be returned.
  ///
  /// [value] An [EvaluationMetric] with type `T` and with the [Name] specified
  /// via `metricName` if it exists in [Metrics]; `null` otherwise.
  ///
  /// [T] The type of the [EvaluationMetric] to be returned.
  (bool, T??) tryGet<T>(String metricName) {
    if (metrics.tryGetValue(metricName, out EvaluationMetric? m) && m is T metric) {
      return (true, metric);
    }
    return (false, default);
  }

  /// Returns an [EvaluationMetric] with type `T` and with the [Name] specified
  /// via `metricName` if it exists in [Metrics].
  ///
  /// Returns: An [EvaluationMetric] with type `T` and with the [Name] specified
  /// via `metricName` if it exists in [Metrics].
  ///
  /// [metricName] The [Name] of the [EvaluationMetric] to be returned.
  ///
  /// [T] The type of the [EvaluationMetric] to be returned.
  T getValue<T>(String metricName) {
    if (metrics.tryGetValue(metricName, out EvaluationMetric? m) && m is T) {
      final metric = metrics.tryGetValue(metricName, out EvaluationMetric? m) && m as T;
      return metric;
    }
    throw keyNotFoundException('Metric '${metricName}' of type '${typeof(T).fullName}' was not found.');
  }
}

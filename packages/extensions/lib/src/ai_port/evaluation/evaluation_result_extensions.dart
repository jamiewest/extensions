import '../../../../../lib/func_typedefs.dart';
import 'evaluation_context.dart';
import 'evaluation_diagnostic.dart';
import 'evaluation_metric_interpretation.dart';
import 'evaluation_result.dart';

/// Extension methods for [EvaluationResult].
extension EvaluationResultExtensions on EvaluationResult {
  /// Adds or updates the supplied `context` objects in all [EvaluationMetric]s
  /// contained in the supplied `result`.
  ///
  /// [result] The [EvaluationResult] containing the [EvaluationMetric]s that
  /// are to be altered.
  ///
  /// [context] The [EvaluationContext] objects to be added or updated.
  void addOrUpdateContextInAllMetrics({Iterable<EvaluationContext>? context}) {
    _ = Throw.ifNull(result);
    for (final metric in result.metrics.values) {
      metric.addOrUpdateContext(context);
    }
  }

  /// Adds the supplied `diagnostics` to all [EvaluationMetric]s contained in
  /// the supplied `result`.
  ///
  /// [result] The [EvaluationResult] containing the [EvaluationMetric]s that
  /// are to be altered.
  ///
  /// [diagnostics] The [EvaluationDiagnostic]s that are to be added.
  void addDiagnosticsToAllMetrics({
    Iterable<EvaluationDiagnostic>? diagnostics,
  }) {
    _ = Throw.ifNull(result);
    for (final metric in result.metrics.values) {
      metric.addDiagnostics(diagnostics);
    }
  }

  /// Returns `true` if any [EvaluationMetric] contained in the supplied
  /// `result` contains an [EvaluationDiagnostic] matching the supplied
  /// `predicate`; `false` otherwise.
  ///
  /// Returns: `true` if any [EvaluationMetric] contained in the supplied
  /// `result` contains an [EvaluationDiagnostic] matching the supplied
  /// `predicate`; `false` otherwise.
  ///
  /// [result] The [EvaluationResult] that is to be inspected.
  ///
  /// [predicate] A predicate that returns `true` if a matching
  /// [EvaluationDiagnostic] is found; `false` otherwise.
  bool containsDiagnostics({Func<EvaluationDiagnostic, bool>? predicate}) {
    _ = Throw.ifNull(result);
    return result.metrics.values.any((m) => m.containsDiagnostics(predicate));
  }

  /// Applies [EvaluationMetricInterpretation]s to one or more
  /// [EvaluationMetric]s contained in the supplied `result`.
  ///
  /// [result] The [EvaluationResult] containing the [EvaluationMetric]s that
  /// are to be interpreted.
  ///
  /// [interpretationProvider] A function that returns a new
  /// [EvaluationMetricInterpretation] that should be applied to the supplied
  /// [EvaluationMetric], or `null` if the [Interpretation] should be left
  /// unchanged.
  void interpret(
    Func<EvaluationMetric, EvaluationMetricInterpretation?>
    interpretationProvider,
  ) {
    _ = Throw.ifNull(result);
    _ = Throw.ifNull(interpretationProvider);
    for (final metric in result.metrics.values) {
      if (interpretationProvider(metric) is EvaluationMetricInterpretation) {
        final interpretation =
            interpretationProvider(metric) as EvaluationMetricInterpretation;
        metric.interpretation = interpretation;
      }
    }
  }

  /// Adds or updates metadata with the specified `name` and `value` in all
  /// [EvaluationMetric]s contained in the supplied `result`.
  ///
  /// [result] The [EvaluationResult] containing the [EvaluationMetric]s that
  /// are to be altered.
  ///
  /// [name] The name of the metadata.
  ///
  /// [value] The value of the metadata.
  void addOrUpdateMetadataInAllMetrics({
    String? name,
    String? value,
    Map<String, String>? metadata,
  }) {
    _ = Throw.ifNull(result);
    for (final metric in result.metrics.values) {
      metric.addOrUpdateMetadata(name, value);
    }
  }

  /// Adds or updates metadata available as part of the evaluation `response`
  /// produced by an AI model, in all [EvaluationMetric]s contained in the
  /// supplied `result`.
  ///
  /// [result] The [EvaluationResult] containing the [EvaluationMetric]s that
  /// are to be altered.
  ///
  /// [response] The [ChatResponse] that contains metadata to be added or
  /// updated.
  ///
  /// [duration] An optional duration that represents the amount of time that it
  /// took for the AI model to produce the supplied `response`. If supplied, the
  /// duration (in milliseconds) will also be included as part of the added
  /// metadata.
  void addOrUpdateChatMetadataInAllMetrics(
    ChatResponse response, {
    Duration? duration,
  }) {
    _ = Throw.ifNull(result);
    for (final metric in result.metrics.values) {
      metric.addOrUpdateChatMetadata(response, duration);
    }
  }

  /// Adds or updates metadata identifying the amount of time (in milliseconds)
  /// that it took to perform the evaluation in all [EvaluationMetric]s
  /// contained in the supplied `result`.
  ///
  /// [result] The [EvaluationResult] containing the [EvaluationMetric]s that
  /// are to be altered.
  ///
  /// [duration] The amount of time that it took to perform the evaluation that
  /// produced the supplied `result`.
  void addOrUpdateDurationMetadataInAllMetrics(Duration duration) {
    _ = Throw.ifNull(result);
    for (final metric in result.metrics.values) {
      metric.addOrUpdateDurationMetadata(duration);
    }
  }
}

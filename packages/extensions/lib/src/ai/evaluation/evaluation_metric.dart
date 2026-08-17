import 'evaluation_context.dart';
import 'evaluation_diagnostic.dart';
import 'evaluation_metric_interpretation.dart';

/// Base class for all evaluation metric results.
class EvaluationMetric {
  /// Creates an [EvaluationMetric] with the given [name] and optional [reason].
  EvaluationMetric(this.name, {this.reason});

  /// The name of this metric.
  String name;

  /// Optional commentary on the metric result.
  String? reason;

  /// Interpretation of whether this result is good or bad, passed or failed.
  EvaluationMetricInterpretation? interpretation;

  /// Contexts considered by the evaluator when producing this metric.
  Map<String, EvaluationContext>? context;

  /// Diagnostic messages associated with this metric.
  List<EvaluationDiagnostic>? diagnostics;

  /// Arbitrary string metadata associated with this metric.
  Map<String, String>? metadata;
}

import 'evaluation_context.dart';
import 'evaluation_diagnostic.dart';
import 'evaluation_metric_interpretation.dart';
import 'evaluator.dart';

/// A base class that represents the result of an evaluation.
///
/// [name] The name of the [EvaluationMetric].
///
/// [reason] An optional string that can be used to provide some commentary
/// around the result represented by this [EvaluationMetric].
class EvaluationMetric {
  /// A base class that represents the result of an evaluation.
  ///
  /// [name] The name of the [EvaluationMetric].
  ///
  /// [reason] An optional string that can be used to provide some commentary
  /// around the result represented by this [EvaluationMetric].
  EvaluationMetric(String name, {String? reason = null}) : name = name;

  /// Gets or sets the name of the [EvaluationMetric].
  String name = name;

  /// Gets or sets a string that can optionally be used to provide some
  /// commentary around the result represented by this [EvaluationMetric].
  String? reason = reason;

  /// Gets or sets an [EvaluationMetricInterpretation] that identifies whether
  /// the result of the evaluation represented by the current [EvaluationMetric]
  /// is considered good or bad, passed or failed etc.
  EvaluationMetricInterpretation? interpretation;

  /// Gets or sets any [EvaluationContext]s that were considered by the
  /// [Evaluator] as part of the evaluation that produced the current
  /// [EvaluationMetric].
  Map<String, EvaluationContext>? context;

  /// Gets or sets a collection of zero or more [EvaluationDiagnostic]s
  /// associated with the current [EvaluationMetric].
  List<EvaluationDiagnostic>? diagnostics;

  /// Gets or sets a collection of zero or more string metadata associated with
  /// the current [EvaluationMetric].
  Map<String, String>? metadata;
}

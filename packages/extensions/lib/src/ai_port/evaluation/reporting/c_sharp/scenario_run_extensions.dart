import '../../evaluation_context.dart';
import '../../evaluation_result.dart';
import '../../evaluator.dart';
import 'scenario_run.dart';

/// Extension methods for [ScenarioRun].
extension ScenarioRunExtensions on ScenarioRun {
  /// Evaluates the supplied `modelResponse` and returns an [EvaluationResult]
  /// containing one or more [EvaluationMetric]s.
  ///
  /// Returns: An [EvaluationResult] containing one or more [EvaluationMetric]s.
  ///
  /// [scenarioRun] The [ScenarioRun] of which this evaluation is a part.
  ///
  /// [modelResponse] The response that is to be evaluated.
  ///
  /// [additionalContext] Additional contextual information that the
  /// [Evaluator]s included in this [ScenarioRun] may need to accurately
  /// evaluate the supplied `modelResponse`.
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the evaluation
  /// operation.
  Future<EvaluationResult> evaluate(
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken cancellationToken, {
    String? modelResponse,
    String? userRequest,
  }) {
    // TODO(ai): implement dispatch
    throw UnimplementedError();
  }
}

import '../../../../../../../lib/func_typedefs.dart';
import '../../evaluation_diagnostic.dart';
import 'scenario_run_result.dart';

/// Extension methods for [ScenarioRunResult].
extension ScenarioRunResultExtensions on ScenarioRunResult {
  /// Returns `true` if any [EvaluationMetric] contained in the supplied
  /// `result` contains an [EvaluationDiagnostic] matching the supplied
  /// `predicate`; `false` otherwise.
  ///
  /// Returns: `true` if any [EvaluationMetric] contained in the supplied
  /// `result` contains an [EvaluationDiagnostic] matching the supplied
  /// `predicate`; `false` otherwise.
  ///
  /// [result] The [ScenarioRunResult] that is to be inspected.
  ///
  /// [predicate] A predicate that returns `true` if a matching
  /// [EvaluationDiagnostic] is found; `false` otherwise.
  bool containsDiagnostics({Func<EvaluationDiagnostic, bool>? predicate}) {
    _ = Throw.ifNull(result);
    return result.evaluationResult.containsDiagnostics(predicate);
  }
}

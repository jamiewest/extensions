import 'scenario_run_result.dart';

/// Generates a report containing all the [EvaluationMetric]s present in the
/// supplied [ScenarioRunResult]s.
abstract class EvaluationReportWriter {
  /// Writes a report containing all the [EvaluationMetric]s present in the
  /// supplied `scenarioRunResults`s.
  ///
  /// Returns: A [ValueTask] that represents the asynchronous operation.
  ///
  /// [scenarioRunResults] A collection of run results from which to generate
  /// the report.
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the operation.
  Future writeReport(
    Iterable<ScenarioRunResult> scenarioRunResults, {
    CancellationToken? cancellationToken,
  });
}

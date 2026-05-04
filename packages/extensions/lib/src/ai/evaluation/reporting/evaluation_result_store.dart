import 'package:extensions/annotations.dart';

import '../../../system/threading/cancellation_token.dart';
import 'scenario_run_result.dart';

/// Stores and retrieves [ScenarioRunResult]s from a backing store.
@Source(
  name: 'IEvaluationResultStore.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Reporting',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Reporting/',
)
abstract class EvaluationResultStore {
  /// Returns [ScenarioRunResult]s, optionally filtered by [executionName],
  /// [scenarioName], and [iterationName].
  ///
  /// Omitting a filter parameter includes all values for that dimension.
  Stream<ScenarioRunResult> readResults({
    String? executionName,
    String? scenarioName,
    String? iterationName,
    CancellationToken? cancellationToken,
  });

  /// Writes [results] to the store.
  Future<void> writeResults(
    Iterable<ScenarioRunResult> results, {
    CancellationToken? cancellationToken,
  });

  /// Deletes results, optionally filtered by [executionName],
  /// [scenarioName], and [iterationName].
  Future<void> deleteResults({
    String? executionName,
    String? scenarioName,
    String? iterationName,
    CancellationToken? cancellationToken,
  });

  /// Returns the execution names of the [count] most recent executions,
  /// ordered from most recent to least recent.
  Future<List<String>> getLatestExecutionNames(
    int count, {
    CancellationToken? cancellationToken,
  });
}

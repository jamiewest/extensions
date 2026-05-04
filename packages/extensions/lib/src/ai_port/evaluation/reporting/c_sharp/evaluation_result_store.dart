import 'scenario_run.dart';
import 'scenario_run_result.dart';

/// Represents a store for [ScenarioRunResult]s.
abstract class EvaluationResultStore {
  /// Returns [ScenarioRunResult]s for [ScenarioRun]s filtered by the specified
  /// `executionName`, `scenarioName`, and `iterationName` from the store.
  ///
  /// Remarks: Returns all [ScenarioRunResult]s in the store if `executionName`,
  /// `scenarioName`, and `iterationName` are all omitted.
  ///
  /// Returns: The matching [ScenarioRunResult]s.
  ///
  /// [executionName] The [ExecutionName] by which the [ScenarioRunResult]s
  /// should be filtered. If omitted, all [ExecutionName]s are considered.
  ///
  /// [scenarioName] The [ScenarioName] by which the [ScenarioRunResult]s should
  /// be filtered. If omitted, all [ScenarioName]s that are in scope based on
  /// the specified `executionName` filter are considered.
  ///
  /// [iterationName] The [IterationName] by which the [ScenarioRunResult]s
  /// should be filtered. If omitted, all [IterationName]s that are in scope
  /// based on the specified `executionName`, and `scenarioName` filters are
  /// considered.
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the operation.
  Stream<ScenarioRunResult> readResults({
    String? executionName,
    String? scenarioName,
    String? iterationName,
    CancellationToken? cancellationToken,
  });

  /// Writes the supplied `results`s to the store.
  ///
  /// Returns: A [ValueTask] that represents the asynchronous operation.
  ///
  /// [results] The [ScenarioRunResult]s to be written.
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the operation.
  Future writeResults(
    Iterable<ScenarioRunResult> results, {
    CancellationToken? cancellationToken,
  });

  /// Deletes [ScenarioRunResult]s for [ScenarioRun]s filtered by the specified
  /// `executionName`, `scenarioName`, and `iterationName` from the store.
  ///
  /// Remarks: Deletes all [ScenarioRunResult]s in the store if `executionName`,
  /// `scenarioName`, and `iterationName` are all omitted.
  ///
  /// Returns: A [ValueTask] that represents the asynchronous operation.
  ///
  /// [executionName] The [ExecutionName] by which the [ScenarioRunResult]s
  /// should be filtered. If omitted, all [ExecutionName]s are considered.
  ///
  /// [scenarioName] The [ScenarioName] by which the [ScenarioRunResult]s should
  /// be filtered. If omitted, all [ScenarioName]s that are in scope based on
  /// the specified `executionName` filter are considered.
  ///
  /// [iterationName] The [IterationName] by which the [ScenarioRunResult]s
  /// should be filtered. If omitted, all [IterationName]s that are in scope
  /// based on the specified `executionName`, and `scenarioName` filters are
  /// considered.
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the operation.
  Future deleteResults({
    String? executionName,
    String? scenarioName,
    String? iterationName,
    CancellationToken? cancellationToken,
  });

  /// Gets the [ExecutionName]s of the most recent `count` executions from the
  /// store (ordered from most recent to least recent).
  ///
  /// Returns: The [ExecutionName]s of the most recent `count` executions from
  /// the store (ordered from most recent to least recent).
  ///
  /// [count] The number of [ExecutionName]s to retrieve.
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the operation.
  Stream<String> getLatestExecutionNames({
    int? count,
    CancellationToken? cancellationToken,
  });

  /// Gets the [ScenarioName]s present in the execution with the specified
  /// `executionName`.
  ///
  /// Returns: The [ScenarioName]s present in the execution with the specified
  /// `executionName`.
  ///
  /// [executionName] The [ExecutionName].
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the operation.
  Stream<String> getScenarioNames(
    String executionName, {
    CancellationToken? cancellationToken,
  });

  /// Gets the [IterationName]s present in the scenario with the specified
  /// `scenarioName` under the execution with the specified `executionName`.
  ///
  /// Returns: The [IterationName]s present in the scenario with the specified
  /// `scenarioName` under the execution with the specified `executionName`.
  ///
  /// [executionName] The [ExecutionName].
  ///
  /// [scenarioName] The [ScenarioName].
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the operation.
  Stream<String> getIterationNames(
    String executionName,
    String scenarioName, {
    CancellationToken? cancellationToken,
  });
}

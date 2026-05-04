import 'scenario_run.dart';

/// Provides a way to get the [DistributedCache] that caches the AI responses
/// associated with a particular [ScenarioRun].
///
/// Remarks: [EvaluationResponseCacheProvider] can be used to set up caching
/// of AI-generated responses (both the AI responses under evaluation as well
/// as the AI responses for the evaluations themselves). When caching is
/// enabled, the AI responses associated with each [ScenarioRun] are stored in
/// the [DistributedCache] that is returned from this
/// [EvaluationResponseCacheProvider]. So long as the inputs (such as the
/// content included in the requests, the AI model being invoked etc.) remain
/// unchanged, subsequent evaluations of the same [ScenarioRun] use the cached
/// responses instead of invoking the AI model to generate new ones. Bypassing
/// the AI model when the inputs remain unchanged results in faster execution
/// at a lower cost.
abstract class EvaluationResponseCacheProvider {
  /// Returns an [DistributedCache] that caches all the AI responses associated
  /// with the [ScenarioRun] with the supplied `scenarioName` and
  /// `iterationName`.
  ///
  /// Returns: An [DistributedCache] that caches all the AI responses associated
  /// with the [ScenarioRun] with the supplied `scenarioName` and
  /// `iterationName`.
  ///
  /// [scenarioName] The [ScenarioName].
  ///
  /// [iterationName] The [IterationName].
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the operation.
  Future<DistributedCache> getCache(
    String scenarioName,
    String iterationName, {
    CancellationToken? cancellationToken,
  });

  /// Deletes cached AI responses for all [ScenarioRun]s.
  ///
  /// Returns: A [ValueTask] that represents the asynchronous operation.
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the operation.
  Future reset({CancellationToken? cancellationToken});

  /// Deletes expired cache entries for all [ScenarioRun]s.
  ///
  /// Returns: A [ValueTask] that represents the asynchronous operation.
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the operation.
  Future deleteExpiredCacheEntries({CancellationToken? cancellationToken});
}

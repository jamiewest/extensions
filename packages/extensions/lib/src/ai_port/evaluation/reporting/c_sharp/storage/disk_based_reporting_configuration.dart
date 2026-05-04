import '../../../../../../../../lib/func_typedefs.dart';
import '../../../../abstractions/chat_completion/chat_client.dart';
import '../../../chat_configuration.dart';
import '../../../evaluation_metric_interpretation.dart';
import '../../../evaluator.dart';
import '../reporting_configuration.dart';
import '../scenario_run.dart';
import '../scenario_run_result.dart';
import 'disk_based_response_cache_provider.dart';
import 'disk_based_result_store.dart';

/// Contains factory method for creating a [ReportingConfiguration] that
/// persists [ScenarioRunResult]s to disk and also uses the disk to cache AI
/// responses.
class DiskBasedReportingConfiguration {
  DiskBasedReportingConfiguration();

  /// Creates a [ReportingConfiguration] that persists [ScenarioRunResult]s to
  /// disk and also uses the disk to cache AI responses.
  ///
  /// Remarks: Note that when `enableResponseCaching` is set to `true`, the
  /// cache keys used for the cached responses are not guaranteed to be stable
  /// across releases of the library. In other words, when you update your code
  /// to reference a newer version of the library, it is possible that old
  /// cached responses (persisted to the cache using older versions of the
  /// library) will no longer be used - instead new responses will be fetched
  /// from the LLM and added to the cache for use in subsequent executions.
  ///
  /// Returns: A [ReportingConfiguration] that persists [ScenarioRunResult]s to
  /// disk and also uses the disk to cache AI responses.
  ///
  /// [storageRootPath] The path to a directory on disk under which the
  /// [ScenarioRunResult]s and all cached AI responses should be stored.
  ///
  /// [evaluators] The set of [Evaluator]s that should be invoked to evaluate AI
  /// responses.
  ///
  /// [chatConfiguration] A [ChatConfiguration] that specifies the [ChatClient]
  /// that is used by AI-based `evaluators` included in the returned
  /// [ReportingConfiguration]. Can be omitted if none of the included
  /// `evaluators` are AI-based.
  ///
  /// [enableResponseCaching] `true` to enable caching of AI responses; `false`
  /// otherwise.
  ///
  /// [timeToLiveForCacheEntries] An optional [TimeSpan] that specifies the
  /// maximum amount of time that cached AI responses should survive in the
  /// cache before they are considered expired and evicted.
  ///
  /// [cachingKeys] An optional collection of unique strings that should be
  /// hashed when generating the cache keys for cached AI responses. See
  /// [CachingKeys] for more information about this concept.
  ///
  /// [executionName] The name of the current execution. See [ExecutionName] for
  /// more information about this concept. Uses a fixed default value
  /// `"Default"` if omitted.
  ///
  /// [evaluationMetricInterpreter] An optional function that can be used to
  /// override [EvaluationMetricInterpretation]s for [EvaluationMetric]s
  /// returned from evaluations that use the returned [ReportingConfiguration].
  /// The supplied function can either return a new
  /// [EvaluationMetricInterpretation] for any [EvaluationMetric] that is
  /// supplied to it, or return `null` if the [Interpretation] should be left
  /// unchanged.
  ///
  /// [tags] A optional set of text tags applicable to all [ScenarioRun]s
  /// created using the returned [ReportingConfiguration].
  static ReportingConfiguration create(
    String storageRootPath,
    Iterable<Evaluator> evaluators, {
    ChatConfiguration? chatConfiguration,
    bool? enableResponseCaching,
    Duration? timeToLiveForCacheEntries,
    Iterable<String>? cachingKeys,
    String? executionName,
    Func<EvaluationMetric, EvaluationMetricInterpretation?>?
    evaluationMetricInterpreter,
    Iterable<String>? tags,
  }) {
    storageRootPath = Path.getFullPath(storageRootPath);
    var responseCacheProvider =
        chatConfiguration != null && enableResponseCaching
        ? diskBasedResponseCacheProvider(
            storageRootPath,
            timeToLiveForCacheEntries,
          )
        : null;
    var resultStore = diskBasedResultStore(storageRootPath);
    return reportingConfiguration(
      evaluators,
      resultStore,
      chatConfiguration,
      responseCacheProvider,
      cachingKeys,
      executionName,
      evaluationMetricInterpreter,
      tags,
    );
  }
}

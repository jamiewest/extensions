import '../../../../../../../lib/func_typedefs.dart';
import '../../../abstractions/chat_completion/chat_client.dart';
import '../../../abstractions/chat_completion/chat_client_metadata.dart';
import '../../../abstractions/chat_completion/chat_options.dart';
import '../../chat_configuration.dart';
import '../../evaluation_metric_interpretation.dart';
import '../../evaluator.dart';
import 'chat_details.dart';
import 'evaluation_response_cache_provider.dart';
import 'evaluation_result_store.dart';
import 'response_caching_chat_client.dart';
import 'scenario_run.dart';
import 'scenario_run_result.dart';
import 'simple_chat_client.dart';

/// Represents the configuration for a set of [ScenarioRun]s that defines the
/// set of [Evaluator]s that should be invoked, the [ChatConfiguration] that
/// should be used by these [Evaluator]s, how the resulting
/// [ScenarioRunResult]s should be persisted, and how AI responses should be
/// cached.
class ReportingConfiguration {
  /// Initializes a new instance of the [ReportingConfiguration] class.
  ///
  /// [evaluators] The set of [Evaluator]s that should be invoked to evaluate AI
  /// responses.
  ///
  /// [resultStore] The [EvaluationResultStore] that should be used to persist
  /// the [ScenarioRunResult]s.
  ///
  /// [chatConfiguration] A [ChatConfiguration] that specifies the [ChatClient]
  /// that is used by AI-based `evaluators` included in this
  /// [ReportingConfiguration]. Can be omitted if none of the included
  /// `evaluators` are AI-based.
  ///
  /// [responseCacheProvider] The [EvaluationResponseCacheProvider] that should
  /// be used to cache AI responses. If omitted, AI responses will not be
  /// cached.
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
  /// returned from evaluations that use this [ReportingConfiguration]. The
  /// supplied function can either return a new [EvaluationMetricInterpretation]
  /// for any [EvaluationMetric] that is supplied to it, or return `null` if the
  /// [Interpretation] should be left unchanged.
  ///
  /// [tags] A optional set of text tags applicable to all [ScenarioRun]s
  /// created using this [ReportingConfiguration].
  ReportingConfiguration(
    Iterable<Evaluator> evaluators,
    EvaluationResultStore resultStore,
    {ChatConfiguration? chatConfiguration = null, EvaluationResponseCacheProvider? responseCacheProvider = null, Iterable<String>? cachingKeys = null, String? executionName = null, Func<EvaluationMetric, EvaluationMetricInterpretation?>? evaluationMetricInterpreter = null, Iterable<String>? tags = null, },
  ) :
      evaluators = [.. evaluators],
      resultStore = resultStore,
      chatConfiguration = chatConfiguration,
      responseCacheProvider = responseCacheProvider,
      cachingKeys = [.. cachingKeys],
      executionName = executionName,
      evaluationMetricInterpreter = evaluationMetricInterpreter,
      tags = tags == null ? null : [.. tags] {
    cachingKeys ??= [];
    if (chatConfiguration != null) {
      cachingKeys = cachingKeys.concat(getCachingKeysForChatClient(chatConfiguration.chatClient));
    }
  }

  /// Gets the set of [Evaluator]s that should be invoked to evaluate AI
  /// responses.
  final List<Evaluator> evaluators;

  /// Gets the [EvaluationResultStore] that should be used to persist the
  /// [ScenarioRunResult]s.
  final EvaluationResultStore resultStore;

  /// Gets a [ChatConfiguration] that specifies the [ChatClient] that is used by
  /// AI-based [Evaluators] included in this [ReportingConfiguration].
  final ChatConfiguration? chatConfiguration;

  /// Gets the [EvaluationResponseCacheProvider] that should be used to cache AI
  /// responses.
  final EvaluationResponseCacheProvider? responseCacheProvider;

  /// Gets the collection of unique strings that should be hashed when
  /// generating the cache keys for cached AI responses.
  ///
  /// Remarks: If no additional caching keys are supplied, then the cache keys
  /// for a cached response are generated based on the content of the AI request
  /// that produced this response, metadata such as model name and endpoint
  /// present in the configured [ChatClient] and the [ChatOptions] that are
  /// supplied as part of generating the response. Additionally, the name of the
  /// scenario and the iteration are always included in the cache key. This
  /// means that the cached responses for a particular scenario and iteration
  /// will not be reused for a different scenario and iteration even if the AI
  /// request content and metadata happen to be the same. Supplying additional
  /// caching keys can be useful when some external factors need to be
  /// considered when deciding whether a cached AI response is still valid. For
  /// example, consider the case where one of the supplied additional caching
  /// keys is the version of the AI model being invoked. If the product moves to
  /// a newer version of the model, then updating the caching key to reflect
  /// this change will cause all cached entries that rely on this caching key to
  /// be invalidated thereby ensuring that the subsequent evaluations will not
  /// use the outdated cached responses produced by the previous model version.
  final List<String> cachingKeys;

  /// Gets the name of the current execution.
  ///
  /// Remarks: See [ExecutionName] for more information about this concept.
  final String executionName;

  /// Gets a function that can be optionally used to override
  /// [EvaluationMetricInterpretation]s for [EvaluationMetric]s returned from
  /// evaluations that use this [ReportingConfiguration].
  ///
  /// Remarks: The supplied function can either return a new
  /// [EvaluationMetricInterpretation] for any [EvaluationMetric] that is
  /// supplied to it, or return `null` if the [Interpretation] should be left
  /// unchanged.
  final Func<EvaluationMetric, EvaluationMetricInterpretation?>? evaluationMetricInterpreter;

  /// Gets an optional set of text tags applicable to all [ScenarioRun]s created
  /// using this [ReportingConfiguration].
  final List<String>? tags;

  /// Creates a new [ScenarioRun] with the specified `scenarioName` and
  /// `iterationName`.
  ///
  /// Returns: A new [ScenarioRun] with the specified `scenarioName` and
  /// `iterationName`.
  ///
  /// [scenarioName] The [ScenarioName].
  ///
  /// [iterationName] The [IterationName]. Uses default value `"1"` if omitted.
  ///
  /// [additionalCachingKeys] An optional collection of unique strings that
  /// should be hashed when generating the cache keys for cached AI responses.
  /// See [CachingKeys] for more information about this concept.
  ///
  /// [additionalTags] A optional set of text tags applicable to this
  /// [ScenarioRun].
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the operation.
  Future<ScenarioRun> createScenarioRun(
    String scenarioName,
    {String? iterationName, Iterable<String>? additionalCachingKeys, Iterable<String>? additionalTags, CancellationToken? cancellationToken, },
  ) async  {
    var chatConfiguration = chatConfiguration;
    var chatDetails = null;
    Iterable<String>? tags;
    if (additionalTags == null) {
      tags = tags;
    } else if (tags == null) {
      tags = additionalTags;
    } else {
      tags = [.. tags, .. additionalTags];
    }
    if (chatConfiguration != null) {
      var originalChatClient = chatConfiguration.chatClient;
      chatDetails = chatDetails();
      var cachingKeys = additionalCachingKeys == null
                    ? [scenarioName, iterationName, .. cachingKeys]
                    : [scenarioName, iterationName, .. cachingKeys, .. additionalCachingKeys];
      #pragma warning disable CA2000
            // CA2000: Dispose objects before they go out of scope.
            // ResponseCachingChatClient and SimpleChatClient are wrappers around the IChatClient supplied by the
            // caller. Disposing them would also dispose the IChatClient supplied by the caller. Disposing this
            // caller-supplied IChatClient within the evaluation library is problematic because the caller would then
            // lose control over its lifetime. We disable this warning because we want to give the caller complete
            // control over the lifetime of the supplied IChatClient.

            IChatClient chatClient;
      if (responseCacheProvider != null) {
        var cache = await responseCacheProvider.getCacheAsync(
                        scenarioName,
                        iterationName,
                        cancellationToken).configureAwait(false);
        chatClient =
                    responseCachingChatClient(
                        originalChatClient,
                        cache,
                        cachingKeys,
                        chatDetails);
      } else {
        chatClient = simpleChatClient(originalChatClient, chatDetails);
      }
      #pragma warning restore CA2000

            chatConfiguration = chatConfiguration(chatClient);
    }
    return scenarioRun(
            scenarioName,
            iterationName,
            executionName,
            evaluators,
            resultStore,
            chatConfiguration,
            evaluationMetricInterpreter,
            chatDetails,
            tags);
  }

  static Iterable<String> getCachingKeysForChatClient(ChatClient chatClient) {
    var metadata = chatClient.getService<ChatClientMetadata>();
    var providerName = metadata?.providerName;
    if (!string.isNullOrWhiteSpace(providerName)) {
      yield providerName!;
    }
    var modelId = metadata?.defaultModelId;
    if (!string.isNullOrWhiteSpace(modelId)) {
      yield modelId!;
    }
  }
}

import '../../../system/threading/cancellation_token.dart';
import 'response_cache.dart';

/// Provides [ResponseCache] instances scoped to a particular scenario run.
///
/// When response caching is enabled, AI-generated responses are stored per
/// scenario/iteration key. Subsequent runs with identical inputs reuse cached
/// responses instead of calling the model again.
abstract class EvaluationResponseCacheProvider {
  /// Returns a [ResponseCache] for responses associated with the given
  /// [scenarioName] and [iterationName].
  Future<ResponseCache> getCache(
    String scenarioName,
    String iterationName, {
    CancellationToken? cancellationToken,
  });

  /// Clears all cached AI responses.
  Future<void> reset({CancellationToken? cancellationToken});

  /// Removes all expired cache entries.
  Future<void> deleteExpiredCacheEntries({
    CancellationToken? cancellationToken,
  });
}

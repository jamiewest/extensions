import '../evaluation_response_cache_provider.dart';
import '../scenario_run.dart';

/// An [EvaluationResponseCacheProvider] that returns an [DistributedCache]
/// that can cache AI responses for a particular [ScenarioRun] under the
/// specified `storageRootPath` on disk.
///
/// [storageRootPath] The path to a directory on disk under which the cached
/// AI responses should be stored.
///
/// [timeToLiveForCacheEntries] An optional [TimeSpan] that specifies the
/// maximum amount of time that cached AI responses should survive in the
/// cache before they are considered expired and evicted.
class DiskBasedResponseCacheProvider
    implements EvaluationResponseCacheProvider {
  /// An [EvaluationResponseCacheProvider] that returns an [DistributedCache]
  /// that can cache AI responses for a particular [ScenarioRun] under the
  /// specified `storageRootPath` on disk.
  ///
  /// [storageRootPath] The path to a directory on disk under which the cached
  /// AI responses should be stored.
  ///
  /// [timeToLiveForCacheEntries] An optional [TimeSpan] that specifies the
  /// maximum amount of time that cached AI responses should survive in the
  /// cache before they are considered expired and evicted.
  DiskBasedResponseCacheProvider(
    String storageRootPath,
    Duration? timeToLiveForCacheEntries, {
    DateTime Function()? provideDateTime = null,
  });

  final DateTime Function() _provideDateTime = () => DateTime.UtcNow;

  @override
  Future<DistributedCache> getCache(
    String scenarioName,
    String iterationName, {
    CancellationToken? cancellationToken,
  }) {
    var cache = diskBasedResponseCache(
      storageRootPath,
      scenarioName,
      iterationName,
      _provideDateTime,
      timeToLiveForCacheEntries,
    );
    return Future<DistributedCache>(cache);
  }

  @override
  Future reset({CancellationToken? cancellationToken}) {
    DiskBasedResponseCache.resetStorage(storageRootPath);
    return Future.value();
  }

  @override
  Future deleteExpiredCacheEntries({CancellationToken? cancellationToken}) {
    return DiskBasedResponseCache.deleteExpiredEntriesAsync(
      storageRootPath,
      _provideDateTime,
      cancellationToken,
    );
  }
}

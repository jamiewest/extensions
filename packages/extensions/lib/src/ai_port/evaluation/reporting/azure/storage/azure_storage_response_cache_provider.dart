import '../../c_sharp/evaluation_response_cache_provider.dart';
import '../../c_sharp/scenario_run.dart';

/// An [EvaluationResponseCacheProvider] that returns an [DistributedCache]
/// that can cache AI responses for a particular [ScenarioRun] under an Azure
/// Storage container.
///
/// [client] A [DataLakeDirectoryClient] with access to an Azure Storage
/// container under which the cached AI responses should be stored.
///
/// [timeToLiveForCacheEntries] An optional [TimeSpan] that specifies the
/// maximum amount of time that cached AI responses should survive in the
/// cache before they are considered expired and evicted.
class AzureStorageResponseCacheProvider
    implements EvaluationResponseCacheProvider {
  /// An [EvaluationResponseCacheProvider] that returns an [DistributedCache]
  /// that can cache AI responses for a particular [ScenarioRun] under an Azure
  /// Storage container.
  ///
  /// [client] A [DataLakeDirectoryClient] with access to an Azure Storage
  /// container under which the cached AI responses should be stored.
  ///
  /// [timeToLiveForCacheEntries] An optional [TimeSpan] that specifies the
  /// maximum amount of time that cached AI responses should survive in the
  /// cache before they are considered expired and evicted.
  AzureStorageResponseCacheProvider(
    DataLakeDirectoryClient client,
    Duration? timeToLiveForCacheEntries, {
    DateTime Function()? provideDateTime = null,
  });

  final DateTime Function() _provideDateTime = () => DateTime.Now;

  @override
  Future<DistributedCache> getCache(
    String scenarioName,
    String iterationName, {
    CancellationToken? cancellationToken,
  }) {
    var cache = azureStorageResponseCache(
      client,
      scenarioName,
      iterationName,
      _provideDateTime,
      timeToLiveForCacheEntries,
    );
    return Future<DistributedCache>(cache);
  }

  @override
  Future reset({CancellationToken? cancellationToken}) {
    return AzureStorageResponseCache.resetStorageAsync(
      client,
      cancellationToken,
    );
  }

  @override
  Future deleteExpiredCacheEntries({CancellationToken? cancellationToken}) {
    return AzureStorageResponseCache.deleteExpiredEntriesAsync(
      client,
      _provideDateTime,
      cancellationToken,
    );
  }
}

import '../../reporting/azure/storage/azure_storage_response_cache_provider.dart';
import '../../reporting/c_sharp/evaluation_response_cache_provider.dart';
import '../../reporting/c_sharp/storage/disk_based_response_cache_provider.dart';
import '../telemetry/telemetry_constants.dart';
import '../telemetry/telemetry_helper.dart';

class CleanCacheCommand {
  const CleanCacheCommand(Logger logger, TelemetryHelper telemetryHelper, );

  Future<int> invoke(
    DirectoryInfo? storageRootDir,
    Uri? endpointUri,
    {CancellationToken? cancellationToken, },
  ) async  {
    var telemetryProperties = new Dictionary<string, string>();
    await logger.executeWithCatchAsync(
            operation: () =>
                telemetryHelper.reportOperationAsync(
                    operationName: EventNames.cleanCacheCommand,
                    operation: () =>
                    {
                        IEvaluationResponseCacheProvider cacheProvider;

                        if (storageRootDir != null)
                        {
                            string storageRootPath = storageRootDir.fullName;
                            logger.logInformation(
                              "Storage root path: {StorageRootPath}",
                              storageRootPath,
                            );
                            logger.logInformation("Deleting expired cache entries...");

                            cacheProvider = diskBasedResponseCacheProvider(storageRootPath);

                            telemetryProperties[PropertyNames.storageType] = PropertyValues.storageTypeDisk;
      }
                        else if (endpointUri != null)
                        {
                            logger.logInformation(
                              "Azure Storage endpoint: {EndpointUri}",
                              endpointUri,
                            );

                            var fsClient = dataLakeDirectoryClient(
                              endpointUri,
                              defaultAzureCredential(),
                            );
                            cacheProvider = azureStorageResponseCacheProvider(fsClient);

                            telemetryProperties[PropertyNames.storageType] = PropertyValues.storageTypeAzure;
      }
                        else
                        {
                            throw invalidOperationException("Either --path or --endpoint must be specified");
      }

                        return cacheProvider.deleteExpiredCacheEntriesAsync(cancellationToken);
                    },
                    properties: telemetryProperties,
                    logger: logger)).configureAwait(false);
    return 0;
  }
}

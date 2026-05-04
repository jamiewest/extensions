import '../../reporting/azure/storage/azure_storage_result_store.dart';
import '../../reporting/c_sharp/evaluation_result_store.dart';
import '../../reporting/c_sharp/storage/disk_based_result_store.dart';
import '../telemetry/telemetry_constants.dart';
import '../telemetry/telemetry_helper.dart';

class CleanResultsCommand {
  const CleanResultsCommand(Logger logger, TelemetryHelper telemetryHelper, );

  Future<int> invoke(
    DirectoryInfo? storageRootDir,
    Uri? endpointUri,
    int lastN,
    {CancellationToken? cancellationToken, },
  ) async  {
    var telemetryProperties = new Dictionary<string, string>
            {
                [PropertyNames.lastN] = lastN.toTelemetryPropertyValue()
            };
    await logger.executeWithCatchAsync(
            operation: () =>
                telemetryHelper.reportOperationAsync(
                    operationName: EventNames.cleanResultsCommand,
                    operation: async valueFuture() =>
                    {
                        IEvaluationResultStore resultStore;

                        if (storageRootDir != null)
                        {
                            string storageRootPath = storageRootDir.fullName;
                            logger.logInformation(
                              "Storage root path: {StorageRootPath}",
                              storageRootPath,
                            );

                            resultStore = diskBasedResultStore(storageRootPath);

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
                            resultStore = azureStorageResultStore(fsClient);

                            telemetryProperties[PropertyNames.storageType] = PropertyValues.storageTypeAzure;
      }
                        else
                        {
                            throw invalidOperationException("Either --path or --endpoint must be specified");
      }

                        if (lastN is 0)
                        {
                            logger.logInformation("Deleting all results...");

                            await resultStore.deleteResultsAsync(
                                cancellationToken: cancellationToken).configureAwait(false);
      }
                        else
                        {
                            logger.logInformation(
                                "Deleting all results except the {LastN} most recent ones...",
                                lastN);

                            HashSet<string> toPreserve = [];

                            await foreach (string executionName in
                                resultStore.getLatestExecutionNamesAsync(
                                    lastN,
                                    cancellationToken).configureAwait(false))
                            {
                                _ = toPreserve.add(executionName);
        }

                            await foreach (string executionName in
                                resultStore.getLatestExecutionNamesAsync(
                                    cancellationToken: cancellationToken).configureAwait(false))
                            {
                                if (!toPreserve.contains(executionName))
                                {
                                    await resultStore.deleteResultsAsync(
                                        executionName,
                                        cancellationToken: cancellationToken).configureAwait(false);
          }
        }
      }
                    },
                    properties: telemetryProperties,
                    logger: logger)).configureAwait(false);
    return 0;
  }
}

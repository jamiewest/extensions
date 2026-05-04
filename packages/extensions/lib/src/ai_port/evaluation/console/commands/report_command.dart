import '../../reporting/azure/storage/azure_storage_result_store.dart';
import '../../reporting/c_sharp/chat_turn_details.dart';
import '../../reporting/c_sharp/evaluation_report_writer.dart';
import '../../reporting/c_sharp/evaluation_result_store.dart';
import '../../reporting/c_sharp/formats/html/html_report_writer.dart';
import '../../reporting/c_sharp/formats/json/json_report_writer.dart';
import '../../reporting/c_sharp/scenario_run_result.dart';
import '../../reporting/c_sharp/storage/disk_based_result_store.dart';
import '../../utilities/model_info.dart';
import '../telemetry/telemetry_constants.dart';
import '../telemetry/telemetry_helper.dart';
import 'report_command_format.dart';

class ReportCommand {
  const ReportCommand(Logger logger, TelemetryHelper telemetryHelper, );

  Future<int> invoke(
    DirectoryInfo? storageRootDir,
    Uri? endpointUri,
    FileInfo outputFile,
    bool openReport,
    int lastN,
    Format format,
    {CancellationToken? cancellationToken, },
  ) async  {
    var telemetryProperties = new Dictionary<string, string>
            {
                [PropertyNames.lastN] = lastN.toTelemetryPropertyValue(),
                [PropertyNames.format] = format.toString(),
                [PropertyNames.openReport] = openReport.toTelemetryPropertyValue()
            };
    await logger.executeWithCatchAsync(
            operation: () =>
                telemetryHelper.reportOperationAsync(
                    operationName: EventNames.reportCommand,
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

                        List<ScenarioRunResult> results = [];
                        string? latestExecutionName = null;

                        int resultId = 0;
                        var usageDetailsByModel =
                            Dictionary<(
                              string? model,
                              string? modelProvider,
                            ), TurnAndTokenUsageDetails>();

                        await foreach (string executionName in
                            resultStore.getLatestExecutionNamesAsync(
                              lastN,
                              cancellationToken,
                            ) .configureAwait(false))
                        {
                            latestExecutionName ??= executionName;

                            await foreach (ScenarioRunResult result in
                                resultStore.readResultsAsync(
                                    executionName,
                                    cancellationToken: cancellationToken).configureAwait(false))
                            {
                                if (result.executionName == latestExecutionName)
                                {
                                    reportScenarioRunResult(
                                        ++resultId,
                                        result,
                                        usageDetailsByModel,
                                        cancellationToken);
          }
                                else
                                {
                                    // Clear the chat data for following executions
                                    result.messages = [];
                                    result.modelResponse = chatResponse();
          }

                                results.add(result);

                                logger.logInformation(
                                    "Execution: {ExecutionName} Scenario: {ScenarioName} Iteration: {IterationName}",
                                    result.executionName,
                                    result.scenarioName,
                                    result.iterationName);
        }
      }

                        reportUsageDetails(usageDetailsByModel, cancellationToken);

                        string outputFilePath = outputFile.fullName;
                        string? outputPath = Path.getDirectoryName(outputFilePath);
                        if (outputPath != null && !Directory.exists(outputPath))
                        {
                            _ = Directory.createDirectory(outputPath);
      }

                        IEvaluationReportWriter reportWriter = format switch
                        {
                            Format.html => htmlReportWriter(outputFilePath),
                            Format.json => jsonReportWriter(outputFilePath),
                            (_) => throw notSupportedException(),
                        };

                        await reportWriter.writeReportAsync(
                          results,
                          cancellationToken,
                        ) .configureAwait(false);
                        logger.logInformation(
                          "Report: {OutputFilePath} [{Format}]",
                          outputFilePath,
                          format,
                        );

                        // See the following issues for reasoning behind this check. We want to avoid opening the
                        // report if this process is running as a service or in a CI pipeline.
                        // https://github.com/dotnet/runtime/issues/770#issuecomment-564700467
                        // https://github.com/dotnet/runtime/issues/66530#issuecomment-1065854289
                        bool isRedirected =
                            System.console.isInputRedirected &&
                            System.console.isOutputRedirected &&
                            System.console.isErrorRedirected;

                        bool isInteractive =
                            Environment.userInteractive && (OperatingSystem.isWindows() || !isRedirected);

                        if (openReport && isInteractive)
                        {
                            // Open the generated report in the default browser.
                            _ = Process.start(
                                processStartInfo());
      }
                    },
                    properties: telemetryProperties,
                    logger: logger)).configureAwait(false);
    return 0;
  }

  void reportScenarioRunResult(
    int resultId,
    ScenarioRunResult result,
    Map<stringmodel, stringmodelProvider, TurnAndTokenUsageDetails> usageDetailsByModel,
    CancellationToken cancellationToken,
  ) {
    logger.executeWithCatch(() =>
        {
            if (result.chatDetails?.turnDetails is IList<ChatTurnDetails> turns)
            {
                foreach (ChatTurnDetails turn in turns)
                {
                    cancellationToken.throwIfCancellationRequested();

                    (string? model, string? modelProvider) key = (turn.model, turn.modelProvider);
                    if (!usageDetailsByModel.tryGetValue(key, out TurnAndTokenUsageDetails? usageDetails))
                    {
                        usageDetails = turnAndTokenUsageDetails();
                        usageDetailsByModel[key] = usageDetails;
          }

                    usageDetails.add(turn);
        }
      }

            string resultIdValue = resultId.toTelemetryPropertyValue();
            ICollection<EvaluationMetric> metrics = result.evaluationResult.metrics.values;

            var properties =
                new Dictionary<string, string>
                {
                    [PropertyNames.scenarioRunResultId] = resultIdValue,
                    [PropertyNames.metricsCount] = metrics.count.toTelemetryPropertyValue()
                };

            telemetryHelper.reportEvent(eventName: EventNames.scenarioRunResult, properties);

            foreach (EvaluationMetric metric in metrics)
            {
                cancellationToken.throwIfCancellationRequested();

                if (metric.isBuiltIn())
                {
                    reportBuiltInMetric(metric, resultIdValue);
        }
      }
        },
        swallowUnhandledExceptions: true);
    /* TODO: unsupported node kind "unknown" */
    // void ReportBuiltInMetric(EvaluationMetric metric, string resultIdValue)
    //         {
      //             // We always want to report the diagnostics counts - even when metric.Diagnostics is null. This is because
      //             // we know that when metric.Diagnostics is null, that means there were no diagnostics (as opposed to
      //             // meaning that diagnostic information was somehow missing or unavailable).
      //             int errorDiagnosticsCount =
      //                 metric.Diagnostics?.Count(d => d.Severity == EvaluationDiagnosticSeverity.Error) ?? 0;
      //             int warningDiagnosticsCount =
      //                 metric.Diagnostics?.Count(d => d.Severity == EvaluationDiagnosticSeverity.Warning) ?? 0;
      //             int informationalDiagnosticsCount =
      //                 metric.Diagnostics?.Count(d => d.Severity == EvaluationDiagnosticSeverity.Informational) ?? 0;
      //
      //             var properties =
      //                 new Dictionary<string, string>
      //                 {
        //                     [PropertyNames.MetricName] = metric.Name,
        //                     [PropertyNames.ScenarioRunResultId] = resultIdValue,
        //                     [PropertyNames.ErrorDiagnosticsCount] = errorDiagnosticsCount.ToTelemetryPropertyValue(),
        //                     [PropertyNames.WarningDiagnosticsCount] = warningDiagnosticsCount.ToTelemetryPropertyValue(),
        //                     [PropertyNames.InformationalDiagnosticsCount] =
        //                         informationalDiagnosticsCount.ToTelemetryPropertyValue()
        //                 };
      //
      //             // We want to omit reporting the below properties (such as token counts) when the corresponding metadata is
      //             // missing. This is because we know that when the metadata is missing, that means the corresponding
      //             // information was not available. For example, it would be wrong to report the token counts as 0 when in
      //             // reality the token count information is missing because it was not available as part of the ChatResponse
      //             // returned from the IChatClient during evaluation.
      //             if (TryGetPropertyValueFromMetadata(BuiltInMetricUtilities.EvalModelMetadataName) is string model)
      //             {
        //                 properties[PropertyNames.Model] = model;
        //             }
      //
      //             if (TryGetPropertyValueFromMetadata(BuiltInMetricUtilities.EvalInputTokensMetadataName)
      //                     is string inputTokenCount)
      //             {
        //                 properties[PropertyNames.InputTokenCount] = inputTokenCount;
        //             }
      //
      //             if (TryGetPropertyValueFromMetadata(BuiltInMetricUtilities.EvalOutputTokensMetadataName)
      //                     is string outputTokenCount)
      //             {
        //                 properties[PropertyNames.OutputTokenCount] = outputTokenCount;
        //             }
      //
      //             if (TryGetPropertyValueFromMetadata(BuiltInMetricUtilities.EvalDurationMillisecondsMetadataName)
      //                     is string durationInMilliseconds)
      //             {
        //                 properties[PropertyNames.DurationInMilliseconds] = durationInMilliseconds;
        //             }
      //
      //             if (metric.Interpretation?.Failed is bool failed)
      //             {
        //                 properties[PropertyNames.IsInterpretedAsFailed] = failed.ToTelemetryPropertyValue();
        //             }
      //
      //             telemetryHelper.ReportEvent(eventName: EventNames.BuiltInMetric, properties);
      //
      //             string? TryGetPropertyValueFromMetadata(string metadataName)
      //             {
        //                 if ((metric.Metadata?.TryGetValue(metadataName, out string? value)) is not true ||
        //                     string.IsNullOrWhiteSpace(value))
        //                 {
          //                     return null;
          //                 }
        //
        //                 return value;
        //             }
      //         }
  }

  void reportUsageDetails(
    Map<stringmodel, stringmodelProvider, TurnAndTokenUsageDetails> usageDetailsByModel,
    CancellationToken cancellationToken,
  ) {
    logger.executeWithCatch(() =>
        {
            foreach (((string? model, string? modelProvider), TurnAndTokenUsageDetails usageDetails)
                in usageDetailsByModel)
            {
                cancellationToken.throwIfCancellationRequested();

                string isModelHostWellKnown = ModelInfo.isModelHostWellKnown(modelProvider).toTelemetryPropertyValue();
                string isModelHostedLocally = ModelInfo.isModelHostedLocally(modelProvider).toTelemetryPropertyValue();
                string cachedTurnCount = usageDetails.cachedTurnCount.toTelemetryPropertyValue();
                string nonCachedTurnCount = usageDetails.nonCachedTurnCount.toTelemetryPropertyValue();

                var properties =
                    new Dictionary<string, string>
                    {
                        [PropertyNames.model] = model.toTelemetryPropertyValue(defaultValue: PropertyValues.unknown),
                        [PropertyNames.modelProvider] =
                            modelProvider.toTelemetryPropertyValue(defaultValue: PropertyValues.unknown),
                        [PropertyNames.isModelHostWellKnown] = isModelHostWellKnown,
                        [PropertyNames.isModelHostedLocally] = isModelHostedLocally,
                        [PropertyNames.cachedTurnCount] = cachedTurnCount,
                        [PropertyNames.nonCachedTurnCount] = nonCachedTurnCount
                    };

                // We want to omit reporting the below token counts when the information is! available. It would be
                // wrong to report the token counts as 0 when in reality the token count information is missing because
                // it was not available as part of the ChatResponses returned from the IChatClients used during
                // evaluation.
                if (usageDetails.cachedInputTokenCount is long cachedInputTokenCount)
                {
                    properties[PropertyNames.cachedInputTokenCount] = cachedInputTokenCount.toTelemetryPropertyValue();
        }

                if (usageDetails.cachedOutputTokenCount is long cachedOutputTokenCount)
                {
                    properties[PropertyNames.cachedOutputTokenCount] =
                        cachedOutputTokenCount.toTelemetryPropertyValue();
        }

                if (usageDetails.nonCachedInputTokenCount is long nonCachedInputTokenCount)
                {
                    properties[PropertyNames.nonCachedInputTokenCount] =
                        nonCachedInputTokenCount.toTelemetryPropertyValue();
        }

                if (usageDetails.nonCachedOutputTokenCount is long nonCachedOutputTokenCount)
                {
                    properties[PropertyNames.nonCachedOutputTokenCount] =
                        nonCachedOutputTokenCount.toTelemetryPropertyValue();
        }

                telemetryHelper.reportEvent(eventName: EventNames.modelUsageDetails, properties);
      }
        },
        swallowUnhandledExceptions: true);
  }
}
class TurnAndTokenUsageDetails {
  TurnAndTokenUsageDetails();

  long cachedTurnCount;

  long nonCachedTurnCount;

  long? cachedInputTokenCount;

  long? nonCachedInputTokenCount;

  long? cachedOutputTokenCount;

  long? nonCachedOutputTokenCount;

  void add(ChatTurnDetails turn) {
    ensureTokenCountsInitialized();
    var isCached = turn.cacheHit ?? false;
    if (isCached) {
      ++cachedTurnCount;
      cachedInputTokenCount += turn.usage?.inputTokenCount;
      cachedOutputTokenCount += turn.usage?.outputTokenCount;
    } else {
      ++nonCachedTurnCount;
      nonCachedInputTokenCount += turn.usage?.inputTokenCount;
      nonCachedOutputTokenCount += turn.usage?.outputTokenCount;
    }
    /* TODO: unsupported node kind "unknown" */
    // void EnsureTokenCountsInitialized()
    //             {
      //                 // If any turn (for a particular model and model provider combination) contains token usage details, we
      //                 // initialize both the cumulative cached token counts as well as the cumulative non-cached token counts
      //                 // (for this model and model provider combination) to 0. This is done so that when all token usage (for
      //                 // a particular model and model provider combination) is non-cached, we can report the cumulative
      //                 // cached token counts (for this model and model provider combination) as 0 (as opposed to treating the
      //                 // cached token counts as unknown and omitting them from the reported event), and vice-versa. The
      //                 // assumption here is that if any turn (for a particular model and model provider combination) contains
      //                 // token usage details, then all other turns (for the same model and model provider combination) will
      //                 // also contain this.
      //
      //                 if (turn.Usage?.InputTokenCount is not null)
      //                 {
        //                     CachedInputTokenCount ??= 0;
        //                     NonCachedInputTokenCount ??= 0;
        //                 }
      //
      //                 if (turn.Usage?.OutputTokenCount is not null)
      //                 {
        //                     CachedOutputTokenCount ??= 0;
        //                     NonCachedOutputTokenCount ??= 0;
        //                 }
      //             }
  }
}

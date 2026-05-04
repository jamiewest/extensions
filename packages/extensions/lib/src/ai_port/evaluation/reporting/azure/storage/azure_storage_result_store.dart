import '../../c_sharp/evaluation_result_store.dart';
import '../../c_sharp/scenario_run_result.dart';
import '../json_serialization/azure_storage_json_utilities.dart';

/// An [EvaluationResultStore] implementation that stores [ScenarioRunResult]s
/// under an Azure Storage container.
///
/// [client] A [DataLakeDirectoryClient] with access to an Azure Storage
/// container under which the [ScenarioRunResult]s should be stored.
class AzureStorageResultStore implements EvaluationResultStore {
  /// An [EvaluationResultStore] implementation that stores [ScenarioRunResult]s
  /// under an Azure Storage container.
  ///
  /// [client] A [DataLakeDirectoryClient] with access to an Azure Storage
  /// container under which the [ScenarioRunResult]s should be stored.
  const AzureStorageResultStore(DataLakeDirectoryClient client);

  @override
  Stream<String> getLatestExecutionNames({int? count, CancellationToken? cancellationToken, }) async  {
    (string path, _) = getResultPath();
    var subClient = client.getSubDirectoryClient(path);
    var paths = [];
    for (final item in subClient.getPathsAsync(cancellationToken: cancellationToken).configureAwait(false)) {
      paths.add(item);
    }
    for (final item in paths.orderByDescending((item) => item.createdOn ?? DateTimeOffset.minValue).take(count ?? 1)) {
      yield getLastSegmentFromPath(item.name);
    }
  }

  @override
  Stream<String> getScenarioNames(
    String executionName,
    {CancellationToken? cancellationToken, },
  ) async  {
    (string path, _) = getResultPath(executionName);
    var subClient = client.getSubDirectoryClient(path);
    for (final item in subClient.getPathsAsync(recursive: false, cancellationToken: cancellationToken).configureAwait(false)) {
      yield getLastSegmentFromPath(item.name);
    }
  }

  @override
  Stream<String> getIterationNames(
    String executionName,
    String scenarioName,
    {CancellationToken? cancellationToken, },
  ) async  {
    (string path, _) = getResultPath(executionName, scenarioName);
    var subClient = client.getSubDirectoryClient(path);
    for (final item in subClient.getPathsAsync(recursive: false, cancellationToken: cancellationToken).configureAwait(false)) {
      yield stripExtension(getLastSegmentFromPath(item.name));
    }
  }

  @override
  Stream<ScenarioRunResult> readResults({String? executionName, String? scenarioName, String? iterationName, CancellationToken? cancellationToken, }) async  {
    (string path, _) = getResultPath(executionName, scenarioName, iterationName);
    var subClient = client.getSubDirectoryClient(path);
    for (final pathItem in subClient.getPathsAsync(recursive: true, cancellationToken: cancellationToken).configureAwait(false)) {
      if (pathItem.isDirectory ?? true) {
        continue;
      }
      var fileClient = client.getParentFileSystemClient().getFileClient(pathItem.name);
      var content = await fileClient.readContentAsync(cancellationToken).configureAwait(false);
      var result = await JsonSerializer.deserializeAsync(
                content.value.content.toStream(),
                AzureStorageJsonUtilities.defaultValue.scenarioRunResultTypeInfo,
                cancellationToken).configureAwait(false)
                    ?? throw jsonException(
                        string.format(
                          CultureInfo.currentCulture,
                          DeserializationFailedMessage,
                          fileClient.name,
                        ) );
      yield result;
    }
  }

  @override
  Future deleteResults({String? executionName, String? scenarioName, String? iterationName, CancellationToken? cancellationToken, }) async  {
    (string path, bool isDir) = getResultPath(executionName, scenarioName, iterationName);
    if (isDir) {
      _ = await client
                    .getSubDirectoryClient(path)
                    .deleteIfExistsAsync(
                      recursive: true,
                      cancellationToken: cancellationToken,
                    ) .configureAwait(false);
    } else {
      _ = await client
                    .getFileClient(path)
                    .deleteIfExistsAsync(cancellationToken: cancellationToken).configureAwait(false);
    }
  }

  @override
  Future writeResults(
    Iterable<ScenarioRunResult> results,
    {CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(results);
    for (final result in results) {
      cancellationToken.throwIfCancellationRequested();
      (
        string path,
        _,
      ) = getResultPath(result.executionName, result.scenarioName, result.iterationName);
      var fileClient = client.getFileClient(path);
      var stream = new();
      await JsonSerializer.serializeAsync(
                stream,
                result,
                AzureStorageJsonUtilities.defaultValue.scenarioRunResultTypeInfo,
                cancellationToken).configureAwait(false);
      _ = stream.seek(0, SeekOrigin.begin);
      _ = await fileClient.uploadAsync(
                    stream,
                    overwrite: true,
                    cancellationToken: cancellationToken).configureAwait(false);
    }
  }

  static String getLastSegmentFromPath(String name) {
    return name.substring(name.lastIndexOf('/') + 1);
  }

  static String stripExtension(String name) {
    return name.substring(0, name.lastIndexOf('.'));
  }

  static stringpathboolisDir getResultPath({String? executionName, String? scenarioName, String? iterationName, }) {
    if (executionName == null) {
      return ('${ResultsRootPrefix}/', isDir: true);
    } else if (scenarioName == null) {
      return ('${ResultsRootPrefix}/${executionName}/', isDir: true);
    } else if (iterationName == null) {
      return ('${ResultsRootPrefix}/${executionName}/${scenarioName}/', isDir: true);
    }
    return (
      '${ResultsRootPrefix}/${executionName}/${scenarioName}/${iterationName}.json',
      isDir: false,
    );
  }
}

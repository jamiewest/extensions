import '../evaluation_result_store.dart';
import '../json_serialization/json_utilities.dart';
import '../scenario_run_result.dart';
import '../utilities/iteration_name_comparer.dart';
import '../utilities/path_validation.dart';

/// An [EvaluationResultStore] implementation that stores [ScenarioRunResult]s
/// on disk.
class DiskBasedResultStore implements EvaluationResultStore {
  /// Initializes a new instance of the [DiskBasedResultStore] class.
  ///
  /// [storageRootPath] The path to a directory on disk under which the
  /// [ScenarioRunResult]s should be stored.
  DiskBasedResultStore(String storageRootPath)
    : _resultsRootPath = Path.combine(storageRootPath, "results") {
    storageRootPath = Path.getFullPath(storageRootPath);
  }

  final String _resultsRootPath;

  @override
  Stream<ScenarioRunResult> readResults({
    String? executionName,
    String? scenarioName,
    String? iterationName,
    CancellationToken? cancellationToken,
  }) async {
    PathValidation.validatePathSegment(executionName, nameof(executionName));
    PathValidation.validatePathSegment(scenarioName, nameof(scenarioName));
    PathValidation.validatePathSegment(iterationName, nameof(iterationName));
    var resultFiles = enumerateResultFiles(
      executionName,
      scenarioName,
      iterationName,
      cancellationToken,
    );
    for (final resultFile in resultFiles) {
      cancellationToken.throwIfCancellationRequested();
      var stream = resultFile.openRead();
      var result = await JsonSerializer.deserializeAsync(
        stream,
        JsonUtilities.defaultValue.scenarioRunResultTypeInfo,
        cancellationToken,
      ).configureAwait(false);
      yield result == null
          ? throw jsonException(
              string.format(
                CultureInfo.currentCulture,
                DeserializationFailedMessage,
                resultFile.fullName,
              ),
            )
          : result;
    }
  }

  @override
  Future writeResults(
    Iterable<ScenarioRunResult> results, {
    CancellationToken? cancellationToken,
  }) async {
    _ = Throw.ifNull(results);
    for (final result in results) {
      cancellationToken.throwIfCancellationRequested();
      PathValidation.validatePathSegment(
        result.executionName,
        nameof(result.executionName),
      );
      PathValidation.validatePathSegment(
        result.scenarioName,
        nameof(result.scenarioName),
      );
      PathValidation.validatePathSegment(
        result.iterationName,
        nameof(result.iterationName),
      );
      var resultDir = directoryInfo(
        PathValidation.ensureWithinRoot(
          _resultsRootPath,
          Path.combine(
            _resultsRootPath,
            result.executionName,
            result.scenarioName,
          ),
        ),
      );
      resultDir.create();
      var resultFile = fileInfo(
        Path.combine(resultDir.fullName, '${result.iterationName}.json'),
      );
      var stream = resultFile.create();
      await JsonSerializer.serializeAsync(
        stream,
        result,
        JsonUtilities.defaultValue.scenarioRunResultTypeInfo,
        cancellationToken,
      ).configureAwait(false);
    }
  }

  @override
  Future deleteResults({
    String? executionName,
    String? scenarioName,
    String? iterationName,
    CancellationToken? cancellationToken,
  }) {
    PathValidation.validatePathSegment(executionName, nameof(executionName));
    PathValidation.validatePathSegment(scenarioName, nameof(scenarioName));
    PathValidation.validatePathSegment(iterationName, nameof(iterationName));
    if (executionName == null &&
        scenarioName == null &&
        iterationName == null) {
      Directory.delete(_resultsRootPath, recursive: true);
      _ = Directory.createDirectory(_resultsRootPath);
    } else if (executionName != null &&
        scenarioName == null &&
        iterationName == null) {
      var executionDir = directoryInfo(
        PathValidation.ensureWithinRoot(
          _resultsRootPath,
          Path.combine(_resultsRootPath, executionName),
        ),
      );
      if (executionDir.exists) {
        executionDir.delete(recursive: true);
      }
    } else if (executionName != null &&
        scenarioName != null &&
        iterationName == null) {
      var scenarioDir = directoryInfo(
        PathValidation.ensureWithinRoot(
          _resultsRootPath,
          Path.combine(_resultsRootPath, executionName, scenarioName),
        ),
      );
      if (scenarioDir.exists) {
        scenarioDir.delete(recursive: true);
      }
    } else if (executionName != null &&
        scenarioName != null &&
        iterationName != null) {
      var resultFile = fileInfo(
        PathValidation.ensureWithinRoot(
          _resultsRootPath,
          Path.combine(
            _resultsRootPath,
            executionName,
            scenarioName,
            '${iterationName}.json',
          ),
        ),
      );
      if (resultFile.exists) {
        resultFile.delete();
      }
    } else {
      var resultFiles = enumerateResultFiles(
        executionName,
        scenarioName,
        iterationName,
        cancellationToken,
      );
      for (final resultFile in resultFiles) {
        cancellationToken.throwIfCancellationRequested();
        var scenarioDir = resultFile.directory!;
        var executionDir = scenarioDir.parent!;
        resultFile.delete();
        if (!scenarioDir.enumerateFileSystemInfos().any()) {
          scenarioDir.delete(recursive: true);
          if (!executionDir.enumerateFileSystemInfos().any()) {
            executionDir.delete(recursive: true);
          }
        }
      }
    }
    return Future.value();
  }

  @override
  Stream<String> getLatestExecutionNames({
    int? count,
    CancellationToken? cancellationToken,
  }) async {
    if (count.hasValue && count <= 0) {
      return;
    }
    var executionDirs = enumerateExecutionDirs(
      cancellationToken: cancellationToken,
    );
    if (count.hasValue) {
      executionDirs = executionDirs.take(count.value);
    }
    for (final executionDir in executionDirs) {
      cancellationToken.throwIfCancellationRequested();
      yield executionDir.name;
    }
  }

  @override
  Stream<String> getScenarioNames(
    String executionName, {
    CancellationToken? cancellationToken,
  }) async {
    PathValidation.validatePathSegment(executionName, nameof(executionName));
    var executionDirs = enumerateExecutionDirs(
      executionName,
      cancellationToken,
    );
    var scenarioDirs = enumerateScenarioDirs(
      executionDirs,
      cancellationToken: cancellationToken,
    );
    for (final scenarioDir in scenarioDirs) {
      cancellationToken.throwIfCancellationRequested();
      yield scenarioDir.name;
    }
  }

  @override
  Stream<String> getIterationNames(
    String executionName,
    String scenarioName, {
    CancellationToken? cancellationToken,
  }) async {
    PathValidation.validatePathSegment(executionName, nameof(executionName));
    PathValidation.validatePathSegment(scenarioName, nameof(scenarioName));
    var resultFiles = enumerateResultFiles(
      executionName,
      scenarioName,
      cancellationToken: cancellationToken,
    );
    for (final resultFile in resultFiles) {
      cancellationToken.throwIfCancellationRequested();
      yield Path.getFileNameWithoutExtension(resultFile.name);
    }
  }

  Iterable<DirectoryInfo> enumerateExecutionDirs({
    String? executionName,
    CancellationToken? cancellationToken,
  }) {
    var resultsDir = directoryInfo(_resultsRootPath);
    if (!resultsDir.exists) {
      return;
    }
    if (executionName == null) {
      var executionDirs = resultsDir
          .enumerateDirectories("*", InTopDirectoryOnly)
          .orderByDescending((d) => d.creationTimeUtc);
      for (final executionDir in executionDirs) {
        cancellationToken.throwIfCancellationRequested();
        yield executionDir;
      }
    } else {
      var executionDir = directoryInfo(
        PathValidation.ensureWithinRoot(
          _resultsRootPath,
          Path.combine(_resultsRootPath, executionName),
        ),
      );
      if (executionDir.exists) {
        yield executionDir;
      }
    }
  }

  static Iterable<DirectoryInfo> enumerateScenarioDirs(
    Iterable<DirectoryInfo> executionDirs, {
    String? scenarioName,
    CancellationToken? cancellationToken,
  }) {
    for (final executionDir in executionDirs) {
      cancellationToken.throwIfCancellationRequested();
      if (scenarioName == null) {
        var scenarioDirs = executionDir
            .enumerateDirectories("*", InTopDirectoryOnly)
            .orderBy((d) => d.name);
        for (final scenarioDir in scenarioDirs) {
          cancellationToken.throwIfCancellationRequested();
          yield scenarioDir;
        }
      } else {
        var scenarioDir = directoryInfo(
          Path.combine(executionDir.fullName, scenarioName),
        );
        if (scenarioDir.exists) {
          yield scenarioDir;
        }
      }
    }
  }

  static Iterable<FileInfo> enumerateResultFiles(
    String? iterationName,
    CancellationToken cancellationToken, {
    Iterable<DirectoryInfo>? scenarioDirs,
    String? executionName,
    String? scenarioName,
  }) {
    for (final scenarioDir in scenarioDirs) {
      cancellationToken.throwIfCancellationRequested();
      if (iterationName == null) {
        var resultFiles = scenarioDir
            .enumerateFiles("*.json", InTopDirectoryOnly)
            .orderBy((f) => f.name, IterationNameComparer.defaultValue);
        for (final resultFile in resultFiles) {
          cancellationToken.throwIfCancellationRequested();
          yield resultFile;
        }
      } else {
        var resultFile = fileInfo(
          Path.combine(scenarioDir.fullName, '${iterationName}.json'),
        );
        if (resultFile.exists) {
          yield resultFile;
        }
      }
    }
  }
}

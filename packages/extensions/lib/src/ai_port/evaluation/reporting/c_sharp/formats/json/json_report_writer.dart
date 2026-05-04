import '../../evaluation_report_writer.dart';
import '../../json_serialization/json_utilities.dart';
import '../../scenario_run_result.dart';
import '../dataset.dart';

/// An [EvaluationReportWriter] that generates a JSON report containing all
/// the [EvaluationMetric]s present in the supplied [ScenarioRunResult]s and
/// writes it to the specified `reportFilePath`.
///
/// [reportFilePath] The path to a file where the report will be written. If
/// the file already exists, it will be overwritten.
class JsonReportWriter implements EvaluationReportWriter {
  /// An [EvaluationReportWriter] that generates a JSON report containing all
  /// the [EvaluationMetric]s present in the supplied [ScenarioRunResult]s and
  /// writes it to the specified `reportFilePath`.
  ///
  /// [reportFilePath] The path to a file where the report will be written. If
  /// the file already exists, it will be overwritten.
  const JsonReportWriter(String reportFilePath);

  @override
  Future writeReport(
    Iterable<ScenarioRunResult> scenarioRunResults, {
    CancellationToken? cancellationToken,
  }) async {
    var dataset = dataset(
      scenarioRunResults.toList(),
      createdAt: DateTime.utcNow,
      generatorVersion: Constants.version,
    );
    var stream = fileStream(
      reportFilePath,
      FileMode.create,
      FileAccess.write,
      FileShare.none,
      bufferSize: 4096,
      useAsync: true,
    );
    await JsonSerializer.serializeAsync(
      stream,
      dataset,
      JsonUtilities.defaultValue.datasetTypeInfo,
      cancellationToken,
    ).configureAwait(false);
  }
}

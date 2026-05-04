import '../../evaluation_report_writer.dart';
import '../../json_serialization/json_utilities.dart';
import '../../scenario_run_result.dart';
import '../dataset.dart';

/// An [EvaluationReportWriter] that generates an HTML report containing all
/// the [EvaluationMetric]s present in the supplied [ScenarioRunResult]s and
/// writes it to the specified `reportFilePath`.
///
/// [reportFilePath] The path to a file where the report will be written. If
/// the file already exists, it will be overwritten.
class HtmlReportWriter implements EvaluationReportWriter {
  /// An [EvaluationReportWriter] that generates an HTML report containing all
  /// the [EvaluationMetric]s present in the supplied [ScenarioRunResult]s and
  /// writes it to the specified `reportFilePath`.
  ///
  /// [reportFilePath] The path to a file where the report will be written. If
  /// the file already exists, it will be overwritten.
  const HtmlReportWriter(String reportFilePath);

  static final String htmlTemplateBefore;

  static final String htmlTemplateAfter;

  @override
  Future writeReport(
    Iterable<ScenarioRunResult> scenarioRunResults,
    {CancellationToken? cancellationToken, },
  ) async  {
    var dataset = dataset(
                scenarioRunResults.toList(),
                createdAt: DateTime.utcNow,
                generatorVersion: Constants.version);
    var json = JsonSerializer.serialize(dataset, JsonUtilities.compact.datasetTypeInfo);
    var htmlEncodedJson = WebUtility.htmlEncode(json);
    var stream = fileStream(
                reportFilePath,
                FileMode.create,
                FileAccess.write,
                FileShare.none,
                bufferSize: 4096,
                useAsync: true);
    var writer = streamWriter(stream, Encoding.utF8);
    #if NET
        await writer.writeAsync(
          htmlTemplateBefore.asMemory(),
          cancellationToken,
        ) .configureAwait(false);
        await writer.writeAsync(
          htmlEncodedJson.asMemory(),
          cancellationToken,
        ) .configureAwait(false);
        await writer.writeAsync(
          htmlTemplateAfter.asMemory(),
          cancellationToken,
        ) .configureAwait(false);
        await writer.flushAsync(cancellationToken).configureAwait(false);
    #else
        await writer.writeAsync(htmlTemplateBefore).configureAwait(false);
    await writer.writeAsync(htmlEncodedJson).configureAwait(false);
    await writer.writeAsync(htmlTemplateAfter).configureAwait(false);
    await writer.flushAsync().configureAwait(false);
  }
}

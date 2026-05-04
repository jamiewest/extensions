import '../scenario_run_result.dart';

class Dataset {
  const Dataset(
    List<ScenarioRunResult> scenarioRunResults,
    DateTime createdAt,
    String? generatorVersion,
  ) : scenarioRunResults = scenarioRunResults,
      createdAt = createdAt,
      generatorVersion = generatorVersion;

  final List<ScenarioRunResult> scenarioRunResults = scenarioRunResults;

  final DateTime createdAt = createdAt;

  final String? generatorVersion = generatorVersion;
}

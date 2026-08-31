import 'dart:io';

import '../../chat_configuration.dart';
import '../../evaluation_metric.dart';
import '../../evaluation_metric_interpretation.dart';
import '../../evaluator.dart';
import '../reporting_configuration.dart';
import 'disk_based_response_cache_provider.dart';
import 'disk_based_result_store.dart';

/// Factory for a fully disk-backed [ReportingConfiguration].
class DiskBasedReportingConfiguration {
  DiskBasedReportingConfiguration._();

  /// Creates a [ReportingConfiguration] that persists [ScenarioRunResult]s and
  /// optionally caches AI responses on disk under [storageRootPath].
  static ReportingConfiguration create(
    String storageRootPath,
    Iterable<Evaluator> evaluators, {
    ChatConfiguration? chatConfiguration,
    bool enableResponseCaching = false,
    Duration responseTimeToLive = const Duration(days: 14),
    Iterable<String>? cachingKeys,
    String? executionName,
    EvaluationMetricInterpretation? Function(EvaluationMetric)?
    evaluationMetricInterpreter,
    Iterable<String>? tags,
  }) {
    final rootPath = Directory(storageRootPath).absolute.path;
    final resultStore = DiskBasedResultStore(rootPath);
    final responseCacheProvider =
        (chatConfiguration != null && enableResponseCaching)
        ? DiskBasedResponseCacheProvider(
            rootPath,
            timeToLive: responseTimeToLive,
          )
        : null;

    return ReportingConfiguration(
      evaluators,
      resultStore,
      chatConfiguration: chatConfiguration,
      responseCacheProvider: responseCacheProvider,
      cachingKeys: cachingKeys,
      executionName: executionName,
      evaluationMetricInterpreter: evaluationMetricInterpreter,
      tags: tags,
    );
  }
}

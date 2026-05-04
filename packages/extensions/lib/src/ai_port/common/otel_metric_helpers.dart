import '../open_telemetry_consts.dart';

/// Shared metric instrument factories for the OpenTelemetry* clients.
class OtelMetricHelpers {
  OtelMetricHelpers();

  /// Creates the standard `gen_ai.client.token.usage` histogram on `meter`.
  static Histogram<int> createGenAITokenUsageHistogram(Meter meter) {
    return meter.createHistogram<int>(
            OpenTelemetryConsts.genAI.client.tokenUsage.name,
            OpenTelemetryConsts.tokensUnit,
            OpenTelemetryConsts.genAI.client.tokenUsage.description,
            advice: new() { HistogramBucketBoundaries = OpenTelemetryConsts.genAI.client.tokenUsage.explicitBucketBoundaries });
  }

  /// Creates the standard `gen_ai.client.operation.duration` histogram on
  /// `meter`.
  static Histogram<double> createGenAIOperationDurationHistogram(Meter meter) {
    return meter.createHistogram<double>(
            OpenTelemetryConsts.genAI.client.operationDuration.name,
            OpenTelemetryConsts.secondsUnit,
            OpenTelemetryConsts.genAI.client.operationDuration.description,
            advice: new() { HistogramBucketBoundaries = OpenTelemetryConsts.genAI.client.operationDuration.explicitBucketBoundaries });
  }
}

import 'open_telemetry_realtime_client.dart';
import 'realtime_client_builder.dart';

/// Extension methods for adding [OpenTelemetryRealtimeClient] to a
/// pipeline.
extension OpenTelemetryRealtimeClientBuilderExtensions
    on RealtimeClientBuilder {
  /// Adds an [OpenTelemetryRealtimeClient] to the pipeline.
  RealtimeClientBuilder useOpenTelemetry({
    String? modelId,
    String? system,
    bool? enableSensitiveData,
  }) => use(
    (inner) => OpenTelemetryRealtimeClient(
      inner,
      modelId: modelId,
      system: system,
      enableSensitiveData: enableSensitiveData,
    ),
  );
}

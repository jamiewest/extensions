import 'hosted_file_client_builder.dart';
import 'open_telemetry_hosted_file_client.dart';

/// Extension methods for adding [OpenTelemetryHostedFileClient] to a
/// pipeline.
extension OpenTelemetryHostedFileClientBuilderExtensions
    on HostedFileClientBuilder {
  /// Adds an [OpenTelemetryHostedFileClient] to the pipeline.
  HostedFileClientBuilder useOpenTelemetry({
    String? system,
    bool? enableSensitiveData,
  }) =>
      use((inner) => OpenTelemetryHostedFileClient(
            inner,
            system: system,
            enableSensitiveData: enableSensitiveData,
          ));
}

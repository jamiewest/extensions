import 'open_telemetry_speech_to_text_client.dart';
import 'speech_to_text_client_builder.dart';

/// Extension methods for adding [OpenTelemetrySpeechToTextClient] to a
/// pipeline.
extension OpenTelemetrySpeechToTextClientBuilderExtensions
    on SpeechToTextClientBuilder {
  /// Adds an [OpenTelemetrySpeechToTextClient] to the pipeline.
  SpeechToTextClientBuilder useOpenTelemetry({
    String? modelId,
    String? system,
    bool? enableSensitiveData,
  }) => use(
    (inner) => OpenTelemetrySpeechToTextClient(
      inner,
      modelId: modelId,
      system: system,
      enableSensitiveData: enableSensitiveData,
    ),
  );
}

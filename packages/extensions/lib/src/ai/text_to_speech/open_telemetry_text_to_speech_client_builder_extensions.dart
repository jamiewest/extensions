import 'open_telemetry_text_to_speech_client.dart';
import 'text_to_speech_client_builder.dart';

/// Extension methods for adding [OpenTelemetryTextToSpeechClient] to a pipeline.
extension OpenTelemetryTextToSpeechClientBuilderExtensions
    on TextToSpeechClientBuilder {
  /// Adds an [OpenTelemetryTextToSpeechClient] to the pipeline.
  TextToSpeechClientBuilder useOpenTelemetry(
          {String? modelId, String? system}) =>
      use((inner) => OpenTelemetryTextToSpeechClient(inner,
          modelId: modelId, system: system));
}

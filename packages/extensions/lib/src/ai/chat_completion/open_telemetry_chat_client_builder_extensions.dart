import 'chat_client_builder.dart';
import 'open_telemetry_chat_client.dart';

/// Extension methods for adding [OpenTelemetryChatClient] to a pipeline.
extension OpenTelemetryChatClientBuilderExtensions on ChatClientBuilder {
  /// Adds an [OpenTelemetryChatClient] to the pipeline.
  ChatClientBuilder useOpenTelemetry({String? modelId, String? system}) =>
      use((inner) =>
          OpenTelemetryChatClient(inner, modelId: modelId, system: system));
}

import '../../../../../lib/func_typedefs.dart';
import 'chat_client_builder.dart';
import 'open_telemetry_chat_client.dart';

/// Provides extensions for configuring [OpenTelemetryChatClient] instances.
extension OpenTelemetryChatClientBuilderExtensions on ChatClientBuilder {
  /// Adds OpenTelemetry support to the chat client pipeline, following the
/// OpenTelemetry Semantic Conventions for Generative AI systems.
///
/// Remarks: The draft specification this follows is available at . The
/// specification is still experimental and subject to change; as such, the
/// telemetry output by this client is also subject to change.
///
/// Returns: The `builder`.
///
/// [builder] The [ChatClientBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] to use to create a logger for
/// logging events.
///
/// [sourceName] An optional source name that will be used on the telemetry
/// data.
///
/// [configure] An optional callback that can be used to configure the
/// [OpenTelemetryChatClient] instance.
ChatClientBuilder useOpenTelemetry({LoggerFactory? loggerFactory, String? sourceName, Action<OpenTelemetryChatClient>? configure, }) {
return Throw.ifNull(builder).use((innerClient, services) =>
        {
            loggerFactory ??= services.getService<LoggerFactory>();

            var chatClient = openTelemetryChatClient(
              innerClient,
              loggerFactory?.createLogger(typeof(OpenTelemetryChatClient)),
              sourceName,
            );
            configure?.invoke(chatClient);

            return chatClient;
        });
 }
 }

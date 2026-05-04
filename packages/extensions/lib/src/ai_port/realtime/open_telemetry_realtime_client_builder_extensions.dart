import '../../../../../lib/func_typedefs.dart';
import '../abstractions/realtime/realtime_client.dart';
import 'open_telemetry_realtime_client.dart';
import 'realtime_client_builder.dart';

/// Provides extensions for configuring OpenTelemetry on an [RealtimeClient]
/// pipeline.
extension OpenTelemetryRealtimeClientBuilderExtensions on RealtimeClientBuilder {
  /// Adds OpenTelemetry support to the realtime client pipeline, following the
/// OpenTelemetry Semantic Conventions for Generative AI systems.
///
/// Remarks: The draft specification this follows is available at . The
/// specification is still experimental and subject to change; as such, the
/// telemetry output by this client is also subject to change. The following
/// standard OpenTelemetry GenAI conventions are supported:
/// `gen_ai.operation.name` - Operation name ("realtime")
/// `gen_ai.request.model` - Model name from options `gen_ai.provider.name` -
/// Provider name from metadata `gen_ai.response.id` - Response ID from
/// ResponseDone messages `gen_ai.usage.input_tokens` - Input token count
/// `gen_ai.usage.output_tokens` - Output token count
/// `gen_ai.request.max_tokens` - Max output tokens from options
/// `gen_ai.system_instructions` - Instructions from options (sensitive data)
/// `gen_ai.conversation.id` - Conversation ID from response
/// `gen_ai.tool.definitions` - Tool definitions (sensitive data)
/// `server.address` / `server.port` - Server endpoint info `error.type` -
/// Error type on failures Additionally, the following realtime-specific
/// custom attributes are supported: `gen_ai.realtime.voice` - Voice setting
/// from options `gen_ai.realtime.output_modalities` - Output modalities
/// (text, audio) `gen_ai.realtime.voice_speed` - Voice speed setting
/// `gen_ai.realtime.session_kind` - Session kind (Realtime/Transcription)
/// Metrics include: `gen_ai.client.operation.duration` - Duration histogram
/// `gen_ai.client.token.usage` - Token usage histogram
///
/// Returns: The `builder`.
///
/// [builder] The [RealtimeClientBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] to use to create a logger for
/// logging events.
///
/// [sourceName] An optional source name that will be used on the telemetry
/// data.
///
/// [configure] An optional callback that can be used to configure the
/// [OpenTelemetryRealtimeClient] instance.
RealtimeClientBuilder useOpenTelemetry({LoggerFactory? loggerFactory, String? sourceName, Action<OpenTelemetryRealtimeClient>? configure, }) {
return Throw.ifNull(builder).use((innerClient, services) =>
        {
            loggerFactory ??= services.getService<LoggerFactory>();

            var logger = loggerFactory?.createLogger(typeof(OpenTelemetryRealtimeClient));
            var client = openTelemetryRealtimeClient(innerClient, logger, sourceName);
            configure?.invoke(client);
            return client;
        });
 }
 }

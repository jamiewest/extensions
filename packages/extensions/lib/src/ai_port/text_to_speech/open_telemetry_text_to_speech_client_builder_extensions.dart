import '../../../../../lib/func_typedefs.dart';
import 'open_telemetry_text_to_speech_client.dart';
import 'text_to_speech_client_builder.dart';

/// Provides extensions for configuring [OpenTelemetryTextToSpeechClient]
/// instances.
extension OpenTelemetryTextToSpeechClientBuilderExtensions on TextToSpeechClientBuilder {
  /// Adds OpenTelemetry support to the text-to-speech client pipeline,
/// following the OpenTelemetry Semantic Conventions for Generative AI
/// systems.
///
/// Remarks: The draft specification this follows is available at . The
/// specification is still experimental and subject to change; as such, the
/// telemetry output by this client is also subject to change.
///
/// Returns: The `builder`.
///
/// [builder] The [TextToSpeechClientBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] to use to create a logger for
/// logging events.
///
/// [sourceName] An optional source name that will be used on the telemetry
/// data.
///
/// [configure] An optional callback that can be used to configure the
/// [OpenTelemetryTextToSpeechClient] instance.
TextToSpeechClientBuilder useOpenTelemetry({LoggerFactory? loggerFactory, String? sourceName, Action<OpenTelemetryTextToSpeechClient>? configure, }) {
return Throw.ifNull(builder).use((innerClient, services) =>
        {
            loggerFactory ??= services.getService<LoggerFactory>();

            var client = openTelemetryTextToSpeechClient(
              innerClient,
              loggerFactory?.createLogger(typeof(OpenTelemetryTextToSpeechClient)),
              sourceName,
            );
            configure?.invoke(client);

            return client;
        });
 }
 }

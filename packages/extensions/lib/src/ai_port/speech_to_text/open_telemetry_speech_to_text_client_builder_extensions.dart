import '../../../../../lib/func_typedefs.dart';
import 'open_telemetry_speech_to_text_client.dart';
import 'speech_to_text_client_builder.dart';

/// Provides extensions for configuring [OpenTelemetrySpeechToTextClient]
/// instances.
extension OpenTelemetrySpeechToTextClientBuilderExtensions on SpeechToTextClientBuilder {
  /// Adds OpenTelemetry support to the speech-to-text client pipeline,
/// following the OpenTelemetry Semantic Conventions for Generative AI
/// systems.
///
/// Remarks: The draft specification this follows is available at . The
/// specification is still experimental and subject to change; as such, the
/// telemetry output by this client is also subject to change.
///
/// Returns: The `builder`.
///
/// [builder] The [SpeechToTextClientBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] to use to create a logger for
/// logging events.
///
/// [sourceName] An optional source name that will be used on the telemetry
/// data.
///
/// [configure] An optional callback that can be used to configure the
/// [OpenTelemetrySpeechToTextClient] instance.
SpeechToTextClientBuilder useOpenTelemetry({LoggerFactory? loggerFactory, String? sourceName, Action<OpenTelemetrySpeechToTextClient>? configure, }) {
return Throw.ifNull(builder).use((innerClient, services) =>
        {
            loggerFactory ??= services.getService<LoggerFactory>();

            var client = openTelemetrySpeechToTextClient(
              innerClient,
              loggerFactory?.createLogger(typeof(OpenTelemetrySpeechToTextClient)),
              sourceName,
            );
            configure?.invoke(client);

            return client;
        });
 }
 }

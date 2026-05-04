import '../../../../../lib/func_typedefs.dart';
import 'hosted_file_client_builder.dart';
import 'open_telemetry_hosted_file_client.dart';

/// Provides extensions for configuring [OpenTelemetryHostedFileClient]
/// instances.
extension OpenTelemetryHostedFileClientBuilderExtensions on HostedFileClientBuilder {
  /// Adds OpenTelemetry support to the hosted file client pipeline.
///
/// Remarks: Since there is currently no OpenTelemetry Semantic Convention for
/// hosted file operations, this implementation uses general client span
/// conventions alongside standard `file.*` registry attributes where
/// applicable. The telemetry output is subject to change as relevant
/// conventions emerge.
///
/// Returns: The `builder`.
///
/// [builder] The [HostedFileClientBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] to use to create a logger for
/// logging events.
///
/// [sourceName] An optional source name that will be used on the telemetry
/// data.
///
/// [configure] An optional callback that can be used to configure the
/// [OpenTelemetryHostedFileClient] instance.
HostedFileClientBuilder useOpenTelemetry({LoggerFactory? loggerFactory, String? sourceName, Action<OpenTelemetryHostedFileClient>? configure, }) {
return Throw.ifNull(builder).use((innerClient, services) =>
        {
            loggerFactory ??= services.getService<LoggerFactory>();

            var client = openTelemetryHostedFileClient(
              innerClient,
              loggerFactory?.createLogger(typeof(OpenTelemetryHostedFileClient)),
              sourceName,
            );
            configure?.invoke(client);

            return client;
        });
 }
 }

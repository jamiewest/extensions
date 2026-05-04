import '../../../../../lib/func_typedefs.dart';
import 'hosted_file_client_builder.dart';
import 'logging_hosted_file_client.dart';

/// Provides extensions for configuring [LoggingHostedFileClient] instances.
extension LoggingHostedFileClientBuilderExtensions on HostedFileClientBuilder {
  /// Adds logging to the hosted file client pipeline.
///
/// Remarks: When the employed [Logger] enables [Trace], the contents of
/// options and results are logged. These may contain sensitive application
/// data. [Trace] is disabled by default and should never be enabled in a
/// production environment. Options and results are not logged at other
/// logging levels.
///
/// Returns: The `builder`.
///
/// [builder] The [HostedFileClientBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] used to create a logger with
/// which logging should be performed. If not supplied, a required instance
/// will be resolved from the service provider.
///
/// [configure] An optional callback that can be used to configure the
/// [LoggingHostedFileClient] instance.
HostedFileClientBuilder useLogging({LoggerFactory? loggerFactory, Action<LoggingHostedFileClient>? configure, }) {
_ = Throw.ifNull(builder);
return builder.use((innerClient, services) =>
        {
            loggerFactory ??= services.getRequiredService<LoggerFactory>();

            // If the factory we resolve is for the null logger, the LoggingHostedFileClient will end up
            // being an expensive nop, so skip adding it and just return the inner client.
            if (loggerFactory == NullLoggerFactory.instance)
            {
                return innerClient;
            }

            var fileClient = loggingHostedFileClient(
              innerClient,
              loggerFactory.createLogger(typeof(LoggingHostedFileClient)),
            );
            configure?.invoke(fileClient);
            return fileClient;
        });
 }
 }

import '../../../../../lib/func_typedefs.dart';
import '../abstractions/realtime/realtime_client.dart';
import 'logging_realtime_client.dart';
import 'realtime_client_builder.dart';

/// Provides extensions for configuring logging on an [RealtimeClient]
/// pipeline.
extension LoggingRealtimeClientBuilderExtensions on RealtimeClientBuilder {
  /// Adds logging to the realtime client pipeline.
///
/// Remarks: When the employed [Logger] enables [Trace], the contents of
/// messages and options are logged. These messages and options may contain
/// sensitive application data. [Trace] is disabled by default and should
/// never be enabled in a production environment. Messages and options are not
/// logged at other logging levels.
///
/// Returns: The `builder`.
///
/// [builder] The [RealtimeClientBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] used to create a logger with
/// which logging should be performed. If not supplied, a required instance
/// will be resolved from the service provider.
///
/// [configure] An optional callback that can be used to configure the
/// [LoggingRealtimeClient] instance.
RealtimeClientBuilder useLogging({LoggerFactory? loggerFactory, Action<LoggingRealtimeClient>? configure, }) {
_ = Throw.ifNull(builder);
return builder.use((innerClient, services) =>
        {
            loggerFactory ??= services.getRequiredService<LoggerFactory>();

            // If the factory we resolve is for the null logger, the LoggingRealtimeClient will end up
            // being an expensive nop, so skip adding it and just return the inner client.
            if (loggerFactory == NullLoggerFactory.instance)
            {
                return innerClient;
            }

            var logger = loggerFactory.createLogger(typeof(LoggingRealtimeClient));
            var client = loggingRealtimeClient(innerClient, logger);
            configure?.invoke(client);
            return client;
        });
 }
 }

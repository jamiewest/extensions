import 'package:extensions/extensions.dart';

/// Configures a [LoggingRealtimeClient] instance.
typedef ConfigureLoggingRealtimeClient = void Function(
    LoggingRealtimeClient client);

/// Provides extensions for adding a [LoggingRealtimeClient] to a pipeline.
///
/// This is an experimental feature.
extension LoggingRealtimeClientBuilderExtensions on RealtimeClientBuilder {
  /// Adds logging to the real-time client pipeline.
  ///
  /// When [loggerFactory] is not supplied, it is resolved from the active
  /// [ServiceProvider]. If the resolved factory is the null logger factory, no
  /// logging client is added.
  RealtimeClientBuilder useLogging({
    LoggerFactory? loggerFactory,
    ConfigureLoggingRealtimeClient? configure,
  }) {
    return useWithServices((innerClient, services) {
      loggerFactory ??= services.getRequiredService<LoggerFactory>();

      if (loggerFactory == NullLoggerFactory.instance) {
        return innerClient;
      }

      final client = LoggingRealtimeClient(
        innerClient,
        logger: loggerFactory!.createLogger('LoggingRealtimeClient'),
      );
      configure?.call(client);
      return client;
    });
  }
}

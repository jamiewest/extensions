import '../../../../../lib/func_typedefs.dart';
import 'chat_client_builder.dart';
import 'logging_chat_client.dart';

/// Provides extensions for configuring [LoggingChatClient] instances.
extension LoggingChatClientBuilderExtensions on ChatClientBuilder {
  /// Adds logging to the chat client pipeline.
///
/// Remarks: When the employed [Logger] enables [Trace], the contents of chat
/// messages and options are logged. These messages and options may contain
/// sensitive application data. [Trace] is disabled by default and should
/// never be enabled in a production environment. Messages and options are not
/// logged at other logging levels.
///
/// Returns: The `builder`.
///
/// [builder] The [ChatClientBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] used to create a logger with
/// which logging should be performed. If not supplied, a required instance
/// will be resolved from the service provider.
///
/// [configure] An optional callback that can be used to configure the
/// [LoggingChatClient] instance.
ChatClientBuilder useLogging({LoggerFactory? loggerFactory, Action<LoggingChatClient>? configure, }) {
_ = Throw.ifNull(builder);
return builder.use((innerClient, services) =>
        {
            loggerFactory ??= services.getRequiredService<LoggerFactory>();

            // If the factory we resolve is for the null logger, the LoggingChatClient will end up
            // being an expensive nop, so skip adding it and just return the inner client.
            if (loggerFactory == NullLoggerFactory.instance)
            {
                return innerClient;
            }

            var chatClient = loggingChatClient(
              innerClient,
              loggerFactory.createLogger(typeof(LoggingChatClient)),
            );
            configure?.invoke(chatClient);
            return chatClient;
        });
 }
 }

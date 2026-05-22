import 'package:extensions/extensions.dart';

typedef ConfigureLoggingChatClient = void Function(LoggingChatClient client);

/// Provides extensions for configuring [LoggingChatClient] instances.
extension LoggingChatClientBuilderExtensions on ChatClientBuilder {
  ChatClientBuilder useLogging({
    LoggerFactory? loggerFactory,
    ConfigureLoggingChatClient? configure,
  }) {
    return useWithServices((innerClient, services) {
      loggerFactory ??= services.getRequiredService<LoggerFactory>();

      // If the factory we resolve is for the null logger, the LoggingChatClient will end up
      // being an expensive nop, so skip adding it and just return the inner client.
      if (loggerFactory == NullLoggerFactory.instance) {
        return innerClient;
      }

      var chatClient = LoggingChatClient(innerClient,
          logger: loggerFactory!.createLogger('LoggingChatClient'));
      configure?.call(chatClient);
      return chatClient;
    });
  }
}

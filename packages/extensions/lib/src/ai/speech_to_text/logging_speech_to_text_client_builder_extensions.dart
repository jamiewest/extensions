import '../../dependency_injection/service_provider_service_extensions.dart';
import '../../logging/logger_factory.dart';
import '../../logging/null_logger_factory.dart';
import 'logging_speech_to_text_client.dart';
import 'speech_to_text_client_builder.dart';

/// Provides extensions for adding [LoggingSpeechToTextClient] to a
/// [SpeechToTextClientBuilder] pipeline.
///
/// This is an experimental feature.
extension LoggingSpeechToTextClientBuilderExtensions
    on SpeechToTextClientBuilder {
  /// Adds logging around speech-to-text operations.
  ///
  /// When [loggerFactory] is omitted, it is resolved from the service
  /// provider at build time. When the resolved factory is the null logger
  /// factory, the client is returned unwrapped.
  SpeechToTextClientBuilder useLogging({
    LoggerFactory? loggerFactory,
    void Function(LoggingSpeechToTextClient client)? configure,
  }) => useWithServices((inner, services) {
    loggerFactory ??= services.getRequiredService<LoggerFactory>();

    if (loggerFactory == NullLoggerFactory.instance) {
      return inner;
    }

    final client = LoggingSpeechToTextClient(
      inner,
      logger: loggerFactory!.createLogger('LoggingSpeechToTextClient'),
    );
    configure?.call(client);
    return client;
  });
}

import '../../../../../lib/func_typedefs.dart';
import 'logging_text_to_speech_client.dart';
import 'text_to_speech_client_builder.dart';

/// Provides extensions for configuring [LoggingTextToSpeechClient] instances.
extension LoggingTextToSpeechClientBuilderExtensions on TextToSpeechClientBuilder {
  /// Adds logging to the text-to-speech client pipeline.
///
/// Remarks: When the employed [Logger] enables [Trace], the contents of
/// messages and options are logged. These messages and options may contain
/// sensitive application data. [Trace] is disabled by default and should
/// never be enabled in a production environment. Messages and options are not
/// logged at other logging levels.
///
/// Returns: The `builder`.
///
/// [builder] The [TextToSpeechClientBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] used to create a logger with
/// which logging should be performed. If not supplied, a required instance
/// will be resolved from the service provider.
///
/// [configure] An optional callback that can be used to configure the
/// [LoggingTextToSpeechClient] instance.
TextToSpeechClientBuilder useLogging({LoggerFactory? loggerFactory, Action<LoggingTextToSpeechClient>? configure, }) {
_ = Throw.ifNull(builder);
return builder.use((innerClient, services) =>
        {
            loggerFactory ??= services.getRequiredService<LoggerFactory>();

            // If the factory we resolve is for the null logger, the LoggingTextToSpeechClient will end up
            // being an expensive nop, so skip adding it and just return the inner client.
            if (loggerFactory == NullLoggerFactory.instance)
            {
                return innerClient;
            }

            var client = loggingTextToSpeechClient(
              innerClient,
              loggerFactory.createLogger(typeof(LoggingTextToSpeechClient)),
            );
            configure?.invoke(client);
            return client;
        });
 }
 }

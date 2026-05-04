import '../../../../../lib/func_typedefs.dart';
import 'logging_speech_to_text_client.dart';
import 'speech_to_text_client_builder.dart';

/// Provides extensions for configuring [LoggingSpeechToTextClient] instances.
extension LoggingSpeechToTextClientBuilderExtensions on SpeechToTextClientBuilder {
  /// Adds logging to the speech-to-text client pipeline.
///
/// Remarks: When the employed [Logger] enables [Trace], the contents of
/// messages and options are logged. These messages and options may contain
/// sensitive application data. [Trace] is disabled by default and should
/// never be enabled in a production environment. Messages and options are not
/// logged at other logging levels.
///
/// Returns: The `builder`.
///
/// [builder] The [SpeechToTextClientBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] used to create a logger with
/// which logging should be performed. If not supplied, a required instance
/// will be resolved from the service provider.
///
/// [configure] An optional callback that can be used to configure the
/// [LoggingSpeechToTextClient] instance.
SpeechToTextClientBuilder useLogging({LoggerFactory? loggerFactory, Action<LoggingSpeechToTextClient>? configure, }) {
_ = Throw.ifNull(builder);
return builder.use((innerClient, services) =>
        {
            loggerFactory ??= services.getRequiredService<LoggerFactory>();

            // If the factory we resolve is for the null logger, the LoggingAudioTranscriptionClient will end up
            // being an expensive nop, so skip adding it and just return the inner client.
            if (loggerFactory == NullLoggerFactory.instance)
            {
                return innerClient;
            }

            var audioClient = loggingSpeechToTextClient(
              innerClient,
              loggerFactory.createLogger(typeof(LoggingSpeechToTextClient)),
            );
            configure?.invoke(audioClient);
            return audioClient;
        });
 }
 }

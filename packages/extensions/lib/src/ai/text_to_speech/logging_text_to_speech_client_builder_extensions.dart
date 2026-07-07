import 'logging_text_to_speech_client.dart';
import 'text_to_speech_client_builder.dart';

/// Provides extensions for adding [LoggingTextToSpeechClient] to a
/// [TextToSpeechClientBuilder] pipeline.
///
/// This is an experimental feature.
extension LoggingTextToSpeechClientBuilderExtensions
    on TextToSpeechClientBuilder {
  /// Adds logging around text-to-speech operations.
  TextToSpeechClientBuilder useLogging({String? loggerName}) =>
      use((inner) => LoggingTextToSpeechClient(inner, loggerName: loggerName));
}

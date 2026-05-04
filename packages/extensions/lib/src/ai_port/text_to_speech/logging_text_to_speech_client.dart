import '../abstractions/text_to_speech/delegating_text_to_speech_client.dart';
import '../abstractions/text_to_speech/text_to_speech_client.dart';
import '../abstractions/text_to_speech/text_to_speech_client_metadata.dart';
import '../abstractions/text_to_speech/text_to_speech_options.dart';
import '../abstractions/text_to_speech/text_to_speech_response.dart';
import '../abstractions/text_to_speech/text_to_speech_response_update.dart';
import '../telemetry_helpers.dart';

/// A delegating text to speech client that logs text to speech operations to
/// an [Logger].
///
/// Remarks: The provided implementation of [TextToSpeechClient] is
/// thread-safe for concurrent use so long as the [Logger] employed is also
/// thread-safe for concurrent use. When the employed [Logger] enables
/// [Trace], the contents of messages and options are logged. These messages
/// and options may contain sensitive application data. [Trace] is disabled by
/// default and should never be enabled in a production environment. Messages
/// and options are not logged at other logging levels.
class LoggingTextToSpeechClient extends DelegatingTextToSpeechClient {
  /// Initializes a new instance of the [LoggingTextToSpeechClient] class.
  ///
  /// [innerClient] The underlying [TextToSpeechClient].
  ///
  /// [logger] An [Logger] instance that will be used for all logging.
  LoggingTextToSpeechClient(
    TextToSpeechClient innerClient,
    Logger logger,
  ) :
      _logger = Throw.ifNull(logger),
      _jsonSerializerOptions = AIJsonUtilities.defaultOptions;

  /// An [Logger] instance used for all logging.
  final Logger _logger;

  /// The [JsonSerializerOptions] to use for serialization of state written to
  /// the logger.
  JsonSerializerOptions _jsonSerializerOptions;

  /// Gets or sets JSON serialization options to use when serializing logging
  /// data.
  JsonSerializerOptions jsonSerializerOptions;

  @override
  Future<TextToSpeechResponse> getAudio(
    String text,
    {TextToSpeechOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logInvokedSensitive(
          nameof(GetAudioAsync),
          asJson(options),
          asJson(this.getService<TextToSpeechClientMetadata>()),
        );
      } else {
        logInvoked(nameof(GetAudioAsync));
      }
    }
    try {
      var response = await base.getAudioAsync(text, options, cancellationToken);
      if (_logger.isEnabled(LogLevel.debug)) {
        // TTS responses always contain binary audio data; avoid serializing it.
                logCompleted(nameof(GetAudioAsync));
      }
      return response;
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled(nameof(GetAudioAsync));
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(nameof(GetAudioAsync), ex);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  Stream<TextToSpeechResponseUpdate> getStreamingAudio(
    String text,
    {TextToSpeechOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logInvokedSensitive(
          nameof(GetStreamingAudioAsync),
          asJson(options),
          asJson(this.getService<TextToSpeechClientMetadata>()),
        );
      } else {
        logInvoked(nameof(GetStreamingAudioAsync));
      }
    }
    IAsyncEnumerator<TextToSpeechResponseUpdate> e;
    try {
      e = base.getStreamingAudioAsync(
        text,
        options,
        cancellationToken,
      ) .getAsyncEnumerator(cancellationToken);
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled(nameof(GetStreamingAudioAsync));
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(nameof(GetStreamingAudioAsync), ex);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
    try {
      var update = null;
      while (true) {
        try {
          if (!await e.moveNextAsync()) {
            break;
          }
          update = e.current;
        } catch (e, s) {
          if (e is OperationCanceledException) {
            final  = e as OperationCanceledException;
            {
              logInvocationCanceled(nameof(GetStreamingAudioAsync));
              rethrow;
            }
          } else       if (e is Exception) {
            final ex = e as Exception;
            {
              logInvocationFailed(nameof(GetStreamingAudioAsync), ex);
              rethrow;
            }
          } else {
            rethrow;
          }
        }
        if (_logger.isEnabled(LogLevel.debug)) {
          // TTS updates always contain binary audio data; avoid serializing it.
                    logStreamingUpdate();
        }
        yield update;
      }
      logCompleted(nameof(GetStreamingAudioAsync));
    } finally {
      await e.disposeAsync();
    }
  }

  String asJson<T>(T value) {
    return TelemetryHelpers.asJson(value, _jsonSerializerOptions);
  }

  void logInvoked(String methodName) {
    // TODO: implement LogInvoked
    // C#:
    throw UnimplementedError('LogInvoked not implemented');
  }

  void logInvokedSensitive(
    String methodName,
    String textToSpeechOptions,
    String textToSpeechClientMetadata,
  ) {
    // TODO: implement LogInvokedSensitive
    // C#:
    throw UnimplementedError('LogInvokedSensitive not implemented');
  }

  void logCompleted(String methodName) {
    // TODO: implement LogCompleted
    // C#:
    throw UnimplementedError('LogCompleted not implemented');
  }

  void logStreamingUpdate() {
    // TODO: implement LogStreamingUpdate
    // C#:
    throw UnimplementedError('LogStreamingUpdate not implemented');
  }

  void logInvocationCanceled(String methodName) {
    // TODO: implement LogInvocationCanceled
    // C#:
    throw UnimplementedError('LogInvocationCanceled not implemented');
  }

  void logInvocationFailed(String methodName, Exception error, ) {
    // TODO: implement LogInvocationFailed
    // C#:
    throw UnimplementedError('LogInvocationFailed not implemented');
  }
}

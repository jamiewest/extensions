import '../abstractions/speech_to_text/delegating_speech_to_text_client.dart';
import '../abstractions/speech_to_text/speech_to_text_client.dart';
import '../abstractions/speech_to_text/speech_to_text_client_metadata.dart';
import '../abstractions/speech_to_text/speech_to_text_options.dart';
import '../abstractions/speech_to_text/speech_to_text_response.dart';
import '../abstractions/speech_to_text/speech_to_text_response_update.dart';
import '../telemetry_helpers.dart';

/// A delegating speech to text client that logs speech to text operations to
/// an [Logger].
///
/// Remarks: The provided implementation of [SpeechToTextClient] is
/// thread-safe for concurrent use so long as the [Logger] employed is also
/// thread-safe for concurrent use. When the employed [Logger] enables
/// [Trace], the contents of messages and options are logged. These messages
/// and options may contain sensitive application data. [Trace] is disabled by
/// default and should never be enabled in a production environment. Messages
/// and options are not logged at other logging levels.
class LoggingSpeechToTextClient extends DelegatingSpeechToTextClient {
  /// Initializes a new instance of the [LoggingSpeechToTextClient] class.
  ///
  /// [innerClient] The underlying [SpeechToTextClient].
  ///
  /// [logger] An [Logger] instance that will be used for all logging.
  LoggingSpeechToTextClient(
    SpeechToTextClient innerClient,
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
  Future<SpeechToTextResponse> getText(
    Stream audioSpeechStream,
    {SpeechToTextOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logInvokedSensitive(
          nameof(GetTextAsync),
          asJson(options),
          asJson(this.getService<SpeechToTextClientMetadata>()),
        );
      } else {
        logInvoked(nameof(GetTextAsync));
      }
    }
    try {
      var response = await base.getTextAsync(audioSpeechStream, options, cancellationToken);
      if (_logger.isEnabled(LogLevel.debug)) {
        if (_logger.isEnabled(LogLevel.trace)) {
          logCompletedSensitive(nameof(GetTextAsync), asJson(response));
        } else {
          logCompleted(nameof(GetTextAsync));
        }
      }
      return response;
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled(nameof(GetTextAsync));
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(nameof(GetTextAsync), ex);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  Stream<SpeechToTextResponseUpdate> getStreamingText(
    Stream audioSpeechStream,
    {SpeechToTextOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logInvokedSensitive(
          nameof(GetStreamingTextAsync),
          asJson(options),
          asJson(this.getService<SpeechToTextClientMetadata>()),
        );
      } else {
        logInvoked(nameof(GetStreamingTextAsync));
      }
    }
    IAsyncEnumerator<SpeechToTextResponseUpdate> e;
    try {
      e = base.getStreamingTextAsync(
        audioSpeechStream,
        options,
        cancellationToken,
      ) .getAsyncEnumerator(cancellationToken);
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled(nameof(GetStreamingTextAsync));
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(nameof(GetStreamingTextAsync), ex);
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
              logInvocationCanceled(nameof(GetStreamingTextAsync));
              rethrow;
            }
          } else       if (e is Exception) {
            final ex = e as Exception;
            {
              logInvocationFailed(nameof(GetStreamingTextAsync), ex);
              rethrow;
            }
          } else {
            rethrow;
          }
        }
        if (_logger.isEnabled(LogLevel.debug)) {
          if (_logger.isEnabled(LogLevel.trace)) {
            logStreamingUpdateSensitive(asJson(update));
          } else {
            logStreamingUpdate();
          }
        }
        yield update;
      }
      logCompleted(nameof(GetStreamingTextAsync));
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
    String speechToTextOptions,
    String speechToTextClientMetadata,
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

  void logCompletedSensitive(String methodName, String speechToTextResponse, ) {
    // TODO: implement LogCompletedSensitive
    // C#:
    throw UnimplementedError('LogCompletedSensitive not implemented');
  }

  void logStreamingUpdate() {
    // TODO: implement LogStreamingUpdate
    // C#:
    throw UnimplementedError('LogStreamingUpdate not implemented');
  }

  void logStreamingUpdateSensitive(String speechToTextResponseUpdate) {
    // TODO: implement LogStreamingUpdateSensitive
    // C#:
    throw UnimplementedError('LogStreamingUpdateSensitive not implemented');
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

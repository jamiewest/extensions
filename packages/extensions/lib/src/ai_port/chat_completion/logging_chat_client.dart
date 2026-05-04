import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_client_metadata.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/chat_completion/chat_response_update.dart';
import '../abstractions/chat_completion/delegating_chat_client.dart';
import '../telemetry_helpers.dart';

/// A delegating chat client that logs chat operations to an [Logger].
///
/// Remarks: The provided implementation of [ChatClient] is thread-safe for
/// concurrent use so long as the [Logger] employed is also thread-safe for
/// concurrent use. When the employed [Logger] enables [Trace], the contents
/// of chat messages and options are logged. These messages and options may
/// contain sensitive application data. [Trace] is disabled by default and
/// should never be enabled in a production environment. Messages and options
/// are not logged at other logging levels.
class LoggingChatClient extends DelegatingChatClient {
  /// Initializes a new instance of the [LoggingChatClient] class.
  ///
  /// [innerClient] The underlying [ChatClient].
  ///
  /// [logger] An [Logger] instance that will be used for all logging.
  LoggingChatClient(
    ChatClient innerClient,
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
  Future<ChatResponse> getResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logInvokedSensitive(
          nameof(GetResponseAsync),
          asJson(messages),
          asJson(options),
          asJson(this.getService<ChatClientMetadata>()),
        );
      } else {
        logInvoked(nameof(GetResponseAsync));
      }
    }
    try {
      var response = await base.getResponseAsync(messages, options, cancellationToken);
      if (_logger.isEnabled(LogLevel.debug)) {
        if (_logger.isEnabled(LogLevel.trace)) {
          logCompletedSensitive(nameof(GetResponseAsync), asJson(response));
        } else {
          logCompleted(nameof(GetResponseAsync));
        }
      }
      return response;
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled(nameof(GetResponseAsync));
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(nameof(GetResponseAsync), ex);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logInvokedSensitive(
          nameof(GetStreamingResponseAsync),
          asJson(messages),
          asJson(options),
          asJson(this.getService<ChatClientMetadata>()),
        );
      } else {
        logInvoked(nameof(GetStreamingResponseAsync));
      }
    }
    IAsyncEnumerator<ChatResponseUpdate> e;
    try {
      e = base.getStreamingResponseAsync(
        messages,
        options,
        cancellationToken,
      ) .getAsyncEnumerator(cancellationToken);
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled(nameof(GetStreamingResponseAsync));
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(nameof(GetStreamingResponseAsync), ex);
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
              logInvocationCanceled(nameof(GetStreamingResponseAsync));
              rethrow;
            }
          } else       if (e is Exception) {
            final ex = e as Exception;
            {
              logInvocationFailed(nameof(GetStreamingResponseAsync), ex);
              rethrow;
            }
          } else {
            rethrow;
          }
        }
        if (_logger.isEnabled(LogLevel.trace)) {
          logStreamingUpdateSensitive(asJson(update));
        }
        yield update;
      }
      logCompleted(nameof(GetStreamingResponseAsync));
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
    String messages,
    String chatOptions,
    String chatClientMetadata,
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

  void logCompletedSensitive(String methodName, String chatResponse, ) {
    // TODO: implement LogCompletedSensitive
    // C#:
    throw UnimplementedError('LogCompletedSensitive not implemented');
  }

  void logStreamingUpdateSensitive(String chatResponseUpdate) {
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

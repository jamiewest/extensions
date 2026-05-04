import '../abstractions/realtime/realtime_client_message.dart';
import '../abstractions/realtime/realtime_client_session.dart';
import '../abstractions/realtime/realtime_server_message.dart';
import '../abstractions/realtime/realtime_session_options.dart';
import '../telemetry_helpers.dart';

/// A delegating realtime session that logs operations to an [Logger].
///
/// Remarks: The provided implementation of [RealtimeClientSession] is
/// thread-safe for concurrent use so long as the [Logger] employed is also
/// thread-safe for concurrent use. When the employed [Logger] enables
/// [Trace], the contents of messages and options are logged. These messages
/// and options may contain sensitive application data. [Trace] is disabled by
/// default and should never be enabled in a production environment. Messages
/// and options are not logged at other logging levels.
class LoggingRealtimeClientSession implements RealtimeClientSession {
  /// Initializes a new instance of the [LoggingRealtimeClientSession] class.
  ///
  /// [innerSession] The underlying [RealtimeClientSession].
  ///
  /// [logger] An [Logger] instance that will be used for all logging.
  LoggingRealtimeClientSession(
    RealtimeClientSession innerSession,
    Logger logger,
  ) :
      _innerSession = Throw.ifNull(innerSession),
      _logger = Throw.ifNull(logger),
      _jsonSerializerOptions = AIJsonUtilities.defaultOptions;

  /// An [Logger] instance used for all logging.
  final Logger _logger;

  /// The inner session to delegate to.
  final RealtimeClientSession _innerSession;

  /// The [JsonSerializerOptions] to use for serialization of state written to
  /// the logger.
  JsonSerializerOptions _jsonSerializerOptions;

  /// Gets or sets JSON serialization options to use when serializing logging
  /// data.
  JsonSerializerOptions jsonSerializerOptions;

  RealtimeSessionOptions? get options {
    return _innerSession.options;
  }

  @override
  Future dispose() async  {
    await _innerSession.disposeAsync().configureAwait(false);
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey, }) {
    _ = Throw.ifNull(serviceType);
    return serviceKey == null && serviceType.isInstanceOfType(this) ? this :
            _innerSession.getService(serviceType, serviceKey);
  }

  @override
  Future send(RealtimeClientMessage message, {CancellationToken? cancellationToken, }) async  {
    _ = Throw.ifNull(message);
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logSendMessageSensitive(getLoggableString(message));
      } else {
        logSendMessage();
      }
    }
    try {
      await _innerSession.sendAsync(message, cancellationToken).configureAwait(false);
      if (_logger.isEnabled(LogLevel.debug)) {
        logCompleted(nameof(SendAsync));
      }
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled(nameof(SendAsync));
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(nameof(SendAsync), ex);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  Stream<RealtimeServerMessage> getStreamingResponse({CancellationToken? cancellationToken}) async  {
    if (_logger.isEnabled(LogLevel.debug)) {
      logInvoked(nameof(GetStreamingResponseAsync));
    }
    IAsyncEnumerator<RealtimeServerMessage> e;
    try {
      e = _innerSession.getStreamingResponseAsync(cancellationToken).getAsyncEnumerator(cancellationToken);
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
      var message = null;
      while (true) {
        try {
          if (!await e.moveNextAsync().configureAwait(false)) {
            break;
          }
          message = e.current;
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
        if (_logger.isEnabled(LogLevel.debug)) {
          if (_logger.isEnabled(LogLevel.trace)) {
            logStreamingServerMessageSensitive(getLoggableString(message));
          } else {
            logStreamingServerMessage();
          }
        }
        yield message;
      }
      logCompleted(nameof(GetStreamingResponseAsync));
    } finally {
      await e.disposeAsync().configureAwait(false);
    }
  }

  String getLoggableString({RealtimeClientMessage? message}) {
    var obj = jsonObject();
    if (message.rawRepresentation is string) {
      final s = message.rawRepresentation as string;
      obj["content"] = s;
    } else if (message.rawRepresentation != null) {
      obj["content"] = asJson(message.rawRepresentation);
    } else if (message.messageId != null) {
      obj["messageId"] = message.messageId;
    }
    return obj.toJsonString();
  }

  String asJson<T>(T value) {
    return TelemetryHelpers.asJson(value, _jsonSerializerOptions);
  }

  void logInvoked(String methodName) {
    // TODO: implement LogInvoked
    // C#:
    throw UnimplementedError('LogInvoked not implemented');
  }

  void logInvokedSensitive(String methodName, String options, ) {
    // TODO: implement LogInvokedSensitive
    // C#:
    throw UnimplementedError('LogInvokedSensitive not implemented');
  }

  void logSendMessage() {
    // TODO: implement LogSendMessage
    // C#:
    throw UnimplementedError('LogSendMessage not implemented');
  }

  void logSendMessageSensitive(String message) {
    // TODO: implement LogSendMessageSensitive
    // C#:
    throw UnimplementedError('LogSendMessageSensitive not implemented');
  }

  void logCompleted(String methodName) {
    // TODO: implement LogCompleted
    // C#:
    throw UnimplementedError('LogCompleted not implemented');
  }

  void logStreamingServerMessage() {
    // TODO: implement LogStreamingServerMessage
    // C#:
    throw UnimplementedError('LogStreamingServerMessage not implemented');
  }

  void logStreamingServerMessageSensitive(String serverMessage) {
    // TODO: implement LogStreamingServerMessageSensitive
    // C#:
    throw UnimplementedError('LogStreamingServerMessageSensitive not implemented');
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

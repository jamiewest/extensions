import '../abstractions/realtime/delegating_realtime_client.dart';
import '../abstractions/realtime/realtime_client.dart';
import '../abstractions/realtime/realtime_client_session.dart';
import '../abstractions/realtime/realtime_session_options.dart';
import 'logging_realtime_client_session.dart';

/// A delegating realtime client that logs operations to an [Logger].
///
/// Remarks: When the employed [Logger] enables [Trace], the contents of
/// messages and options are logged. These messages and options may contain
/// sensitive application data. [Trace] is disabled by default and should
/// never be enabled in a production environment. Messages and options are not
/// logged at other logging levels.
class LoggingRealtimeClient extends DelegatingRealtimeClient {
  /// Initializes a new instance of the [LoggingRealtimeClient] class.
  ///
  /// [innerClient] The inner [RealtimeClient].
  ///
  /// [logger] An [Logger] instance that will be used for all logging.
  LoggingRealtimeClient(RealtimeClient innerClient, Logger logger)
    : _logger = Throw.ifNull(logger),
      _jsonSerializerOptions = AIJsonUtilities.defaultOptions;

  final Logger _logger;

  JsonSerializerOptions _jsonSerializerOptions;

  /// Gets or sets JSON serialization options to use when serializing logging
  /// data.
  JsonSerializerOptions jsonSerializerOptions;

  @override
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    var innerSession = await base
        .createSessionAsync(options, cancellationToken)
        .configureAwait(false);
    return loggingRealtimeClientSession(innerSession, _logger);
  }
}

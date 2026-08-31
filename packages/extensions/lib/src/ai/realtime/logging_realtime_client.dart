import '../../logging/logger.dart';
import '../../system/threading/cancellation_token.dart';
import 'delegating_realtime_client.dart';
import 'logging_realtime_client_session.dart';
import 'realtime_client_session.dart';
import 'realtime_session_options.dart';

/// A delegating real-time client that logs operations to a [Logger].
///
/// Sessions created by this client are wrapped in a
/// [LoggingRealtimeClientSession] so their interactions are logged too.
///
/// This is an experimental feature.
class LoggingRealtimeClient extends DelegatingRealtimeClient {
  /// Creates a new [LoggingRealtimeClient].
  LoggingRealtimeClient(super.innerClient, {required this._logger});

  final Logger _logger;

  @override
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final innerSession = await super.createSession(
      options: options,
      cancellationToken: cancellationToken,
    );
    return LoggingRealtimeClientSession(innerSession, logger: _logger);
  }
}

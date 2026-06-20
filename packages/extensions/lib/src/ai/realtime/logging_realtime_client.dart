import 'package:extensions/annotations.dart';

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
@Source(
  name: 'LoggingRealtimeClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class LoggingRealtimeClient extends DelegatingRealtimeClient {
  /// Creates a new [LoggingRealtimeClient].
  LoggingRealtimeClient(
    super.innerClient, {
    required Logger logger,
  }) : _logger = logger;

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

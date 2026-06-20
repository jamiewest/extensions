import '../../system/threading/cancellation_token.dart';
import 'realtime_client.dart';
import 'realtime_client_session.dart';
import 'realtime_session_options.dart';

/// Provides an optional base class for a [RealtimeClient] that passes through
/// calls to another instance.
///
/// This is recommended as a base type when building clients that can be chained
/// around an underlying [RealtimeClient]. The default implementation simply
/// passes each call to the inner client instance.
///
/// This is an experimental feature.
abstract class DelegatingRealtimeClient implements RealtimeClient {
  /// Initializes a new instance of the [DelegatingRealtimeClient] class.
  DelegatingRealtimeClient(this.innerClient);

  /// The inner client to delegate to.
  final RealtimeClient innerClient;

  @override
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.createSession(
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  T? getService<T>({Object? key}) => innerClient.getService<T>(key: key);

  @override
  void dispose() => innerClient.dispose();
}

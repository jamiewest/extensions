import 'realtime_client.dart';
import 'realtime_client_session.dart';
import 'realtime_session_options.dart';

/// Provides an optional base class for an [RealtimeClient] that passes
/// through calls to another instance.
///
/// Remarks: This is recommended as a base type when building clients that can
/// be chained around an underlying [RealtimeClient]. The default
/// implementation simply passes each call to the inner client instance.
class DelegatingRealtimeClient implements RealtimeClient {
  /// Initializes a new instance of the [DelegatingRealtimeClient] class.
  ///
  /// [innerClient] The wrapped client instance.
  const DelegatingRealtimeClient(RealtimeClient innerClient)
    : innerClient = Throw.ifNull(innerClient);

  /// Gets the inner [RealtimeClient].
  final RealtimeClient innerClient;

  /// Provides a mechanism for releasing unmanaged resources.
  ///
  /// [disposing] `true` if being called from [Dispose]; otherwise, `false`.
  @override
  void dispose({bool? disposing}) {
    if (disposing) {
      innerClient.dispose();
    }
  }

  @override
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerClient.createSessionAsync(options, cancellationToken);
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey}) {
    _ = Throw.ifNull(serviceType);
    return serviceKey == null && serviceType.isInstanceOfType(this)
        ? this
        : innerClient.getService(serviceType, serviceKey);
  }
}

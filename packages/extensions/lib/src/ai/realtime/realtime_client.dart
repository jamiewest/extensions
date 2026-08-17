import '../../system/disposable.dart';
import '../../system/threading/cancellation_token.dart';
import 'realtime_client_session.dart';
import 'realtime_session_options.dart';

/// Represents a real-time client.
///
/// Provides methods to create and manage real-time sessions.
///
/// This is an experimental feature.
abstract class RealtimeClient implements Disposable {
  /// Creates a new real-time session with the specified [options].
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Asks the client for an object of the specified type [T].
  ///
  /// Returns the found object, or `null` if no matching service is available.
  T? getService<T>({Object? key});
}

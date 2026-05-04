import 'realtime_client_session.dart';
import 'realtime_session_options.dart';

/// Represents a real-time client.
///
/// Remarks: This interface provides methods to create and manage real-time
/// sessions.
abstract class RealtimeClient implements Disposable {
  /// Creates a new real-time session with the specified options.
  ///
  /// Returns: The created real-time session.
  ///
  /// [options] The session options.
  ///
  /// [cancellationToken] A token to cancel the operation.
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Asks the [RealtimeClient] for an object of the specified type
  /// `serviceType`.
  ///
  /// Remarks: The purpose of this method is to allow for the retrieval of
  /// strongly typed services that might be provided by the [RealtimeClient],
  /// including itself or any services it might be wrapping.
  ///
  /// Returns: The found object, otherwise `null`.
  ///
  /// [serviceType] The type of object being requested.
  ///
  /// [serviceKey] An optional key that can be used to help identify the target
  /// service.
  Object? getService(Type serviceType, {Object? serviceKey});
}

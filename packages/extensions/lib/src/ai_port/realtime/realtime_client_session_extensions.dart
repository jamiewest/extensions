import '../abstractions/realtime/realtime_client_session.dart';

/// Provides a collection of static methods for extending
/// [RealtimeClientSession] instances.
extension RealtimeClientSessionExtensions on RealtimeClientSession {
  /// Asks the [RealtimeClientSession] for an object of type `TService`.
///
/// Remarks: The purpose of this method is to allow for the retrieval of
/// strongly typed services that may be provided by the
/// [RealtimeClientSession], including itself or any services it might be
/// wrapping.
///
/// Returns: The found object, otherwise `null`.
///
/// [session] The session.
///
/// [serviceKey] An optional key that can be used to help identify the target
/// service.
///
/// [TService] The type of the object to be retrieved.
TService? getService<TService>({Object? serviceKey}) {
_ = Throw.ifNull(session);
return session.getService(typeof(TService), serviceKey) is TService service ? service : default;
 }
/// Asks the [RealtimeClientSession] for an object of the specified type
/// `serviceType` and throws an exception if one isn't available.
///
/// Remarks: The purpose of this method is to allow for the retrieval of
/// services that are required to be provided by the [RealtimeClientSession],
/// including itself or any services it might be wrapping.
///
/// Returns: The found object.
///
/// [session] The session.
///
/// [serviceType] The type of object being requested.
///
/// [serviceKey] An optional key that can be used to help identify the target
/// service.
Object getRequiredService(Object? serviceKey, {Type? serviceType, }) {
_ = Throw.ifNull(session);
_ = Throw.ifNull(serviceType);
return session.getService(serviceType, serviceKey) ??
            throw Throw.createMissingServiceException(serviceType, serviceKey);
 }
 }

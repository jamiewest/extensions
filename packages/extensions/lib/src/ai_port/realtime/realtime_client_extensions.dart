import '../abstractions/realtime/realtime_client.dart';

/// Provides a collection of static methods for extending [RealtimeClient]
/// instances.
extension RealtimeClientExtensions on RealtimeClient {
  /// Asks the [RealtimeClient] for an object of type `TService`.
///
/// Remarks: The purpose of this method is to allow for the retrieval of
/// strongly typed services that may be provided by the [RealtimeClient],
/// including itself or any services it might be wrapping.
///
/// Returns: The found object, otherwise `null`.
///
/// [client] The client.
///
/// [serviceKey] An optional key that can be used to help identify the target
/// service.
///
/// [TService] The type of the object to be retrieved.
TService? getService<TService>({Object? serviceKey}) {
_ = Throw.ifNull(client);
return client.getService(typeof(TService), serviceKey) is TService service ? service : default;
 }
/// Asks the [RealtimeClient] for an object of the specified type
/// `serviceType` and throws an exception if one isn't available.
///
/// Remarks: The purpose of this method is to allow for the retrieval of
/// services that are required to be provided by the [RealtimeClient],
/// including itself or any services it might be wrapping.
///
/// Returns: The found object.
///
/// [client] The client.
///
/// [serviceType] The type of object being requested.
///
/// [serviceKey] An optional key that can be used to help identify the target
/// service.
Object getRequiredService(Object? serviceKey, {Type? serviceType, }) {
_ = Throw.ifNull(client);
_ = Throw.ifNull(serviceType);
return client.getService(serviceType, serviceKey) ??
            throw Throw.createMissingServiceException(serviceType, serviceKey);
 }
 }

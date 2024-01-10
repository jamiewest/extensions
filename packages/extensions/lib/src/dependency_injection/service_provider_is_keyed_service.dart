import 'service_provider_is_service.dart';

/// Optional service used to determine if the specified type with the
/// specified service key is available from the [ServiceProvider].
abstract class ServiceProviderIsKeyedService
    implements ServiceProviderIsService {
  /// Determines if the specified service type with the specified service
  /// key is available from the [ServiceProvider].
  bool isKeyedService({
    required Type serviceType,
    Object? serviceKey,
  });
}

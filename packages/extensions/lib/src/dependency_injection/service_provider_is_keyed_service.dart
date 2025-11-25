import 'service_provider.dart';
import 'service_provider_is_service.dart';

/// Optional service used to determine if the specified type with the
/// specified service key is available from the [ServiceProvider].
///
/// Adapted from [Microsoft.Extensions.DependencyInjection.IServiceProviderIsKeyedService](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.iserviceprovideriskeyedservice)
abstract interface class ServiceProviderIsKeyedService
    implements ServiceProviderIsService {
  /// Determines if the specified service type with the specified service
  /// key is available from the [ServiceProvider].
  bool isKeyedService(Type serviceType, Object? serviceKey);
}

import 'service_provider.dart';
import 'service_scope.dart';
import 'service_scope_factory.dart';
import 'support_required_service.dart';

/// Extension methods for getting services from a [ServiceProvider].
extension ServiceProviderServiceExtensions on ServiceProvider {
  /// Get service of type [T] from the [ServiceProvider].
  T getRequiredService<T>() {
    if (this is SupportRequiredService) {
      return (this as SupportRequiredService).getRequiredService(serviceType: T)
          as T;
    }
    var service = getService<T>();
    if (service == null) {
      throw Exception(
          'No service for type \'${T.toString()}\' has been registered.');
    }
    return service;
  }

  /// Creates a new [ServiceScope] that can be used to resolve scoped services.
  ServiceScope createScope() =>
      getRequiredService<ServiceScopeFactory>().createScope();
}

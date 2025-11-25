import '../system/exceptions/invalid_operation_exception.dart';
import 'keyed_service_provider.dart';
import 'service_provider.dart';

/// Extension methods for getting services from a [ServiceProvider].
extension ServiceProviderKeyedServiceExtensions on ServiceProvider {
  /// Get service of type [T] from the [ServiceProvider].
  T? getKeyedService<T>(Object? serviceKey) {
    if (this is KeyedServiceProvider) {
      var service =
          (this as KeyedServiceProvider).getKeyedServiceFromType(T, serviceKey);
      if (service != null) {
        return service as T;
      }
      return null;
    }

    throw InvalidOperationException(
      message: 'This service provider doesn\'t support keyed services.',
    );
  }

  /// /// Get service of type [serviceType] from the [ServiceProvider].
  Object getRequiredKeyedServiceFromType(
    Type serviceType,
    Object? serviceKey,
  ) {
    if (this is KeyedServiceProvider) {
      return (this as KeyedServiceProvider).getRequiredKeyedServiceFromType(
        serviceType,
        serviceKey,
      );
    }

    throw InvalidOperationException(
      message: 'This service provider doesn\'t support keyed services.',
    );
  }

  /// Get service of type [T] from the [ServiceProvider].
  T getRequiredKeyedService<T>(Object? serviceKey) =>
      getRequiredKeyedServiceFromType(T, serviceKey) as T;

  /// Get an enumeration of services of type [T] from the [ServiceProvider].
  Iterable<T> getKeyedServices<T>(Object? serviceKey) =>
      getKeyedServicesFromType(T, serviceKey) as Iterable<T>;

  /// Get an enumeration of services of type [serviceType] from
  /// the [ServiceProvider].
  Iterable<Object> getKeyedServicesFromType(
          Type serviceType, Object? serviceKey) =>
      getRequiredKeyedServiceFromType(serviceType, serviceKey)
          as Iterable<Object>;
}

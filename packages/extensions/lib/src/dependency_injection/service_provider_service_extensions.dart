import '../common/async_disposable.dart';
import 'async_service_scope.dart';
import 'service_provider.dart';
import 'service_scope.dart';
import 'service_scope_factory.dart';
import 'support_required_service.dart';

/// Extension methods for getting services from a [ServiceProvider].
extension ServiceProviderServiceExtensions on ServiceProvider {
  /// Get service of type [T] from the [ServiceProvider].
  T? getService<T>() {
    return getServiceFromType(T) as T;
  }

  /// Get service of type [serviceType] from the [ServiceProvider].
  Object getRequiredServiceFromType(Type serviceType) {
    if (this is SupportRequiredService) {
      return (this as SupportRequiredService).getRequiredService(serviceType);
    }

    Object? service = getServiceFromType(serviceType);
    if (service == null) {
      throw Exception(
        'No service for type \'${serviceType.runtimeType.toString()}\''
        ' has been registered.',
      );
    }

    return service;
  }

  /// Get service of type [T] from the [ServiceProvider].
  T getRequiredService<T>() {
    return getRequiredServiceFromType(T) as T;
  }

  /// Get an enumeration of services of type [T] from the [ServiceProvider].
  Iterable<T> getServices<T>() {
    return getRequiredService<T>() as Iterable<T>;
  }

  /// Get an enumeration of services of type [serviceType] from
  /// the [ServiceProvider].
  Iterable<Object> getServicesFromType(Type serviceType) {
    return getRequiredServiceFromType(serviceType) as Iterable<Object>;
  }

  /// Creates a new [ServiceScope] that can be used to resolve scoped services.
  ServiceScope createScope() =>
      getRequiredService<ServiceScopeFactory>().createScope();

  /// Creates a new [AsyncServiceScope] that can be used to resolve scoped
  /// services.
  AsyncDisposable createAsyncScope() => AsyncServiceScope(createScope());
}

/// Extension methods for getting services from a [ServiceScopeFactory].
extension ServiceScopeFactoryExtensions on ServiceScopeFactory {
  /// Creates a new [AsyncServiceScope] that can be used to resolve scoped
  /// services.
  AsyncDisposable createAsyncScope() => AsyncServiceScope(createScope());
}

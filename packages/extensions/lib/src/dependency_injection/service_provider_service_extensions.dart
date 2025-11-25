import '../system/async_disposable.dart';
import '../system/exceptions/invalid_operation_exception.dart';
import 'async_service_scope.dart';
import 'service_provider.dart';
import 'service_scope.dart';
import 'service_scope_factory.dart';
import 'support_required_service.dart';

/// Extension methods for getting services from a [ServiceProvider].
extension ServiceProviderServiceExtensions on ServiceProvider {
  /// Get service of type [T] from the [ServiceProvider].
  T? getService<T>() {
    final service = getServiceFromType(T);
    if (service != null) {
      return service as T;
    }
    return null;
  }

  /// Get service of type [serviceType] from the [ServiceProvider].
  Object getRequiredServiceFromType(Type serviceType) {
    if (this is SupportRequiredService) {
      return (this as SupportRequiredService).getRequiredService(serviceType);
    }

    var service = getServiceFromType(serviceType);
    if (service == null) {
      throw InvalidOperationException(
        message: 'No service for type \'${serviceType.runtimeType.toString()}\''
            ' has been registered.',
      );
    }

    return service;
  }

  /// Get service of type [T] from the [ServiceProvider].
  T getRequiredService<T>() => getRequiredServiceFromType(T) as T;

  /// Get an enumeration of services of type [T] from the [ServiceProvider].
  Iterable<T> getServices<T>() {
    var result = getServiceFromType(Iterable<T>);

    if (result is List<dynamic>) {
      return result.cast<T>();
    }

    return List<T>.empty();

    //throw Exception('No service found for registered type.');
  }

  /// Get an enumeration of services of type [serviceType] from
  /// the [ServiceProvider].
  Iterable<Object> getServicesFromType(Type serviceType) =>
      getRequiredServiceFromType(serviceType) as Iterable<Object>;

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

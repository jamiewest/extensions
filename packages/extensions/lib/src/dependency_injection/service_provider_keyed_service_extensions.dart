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
  Iterable<T> getKeyedServices<T>(Object? serviceKey) {
    if (this is KeyedServiceProvider) {
      final result = (this as KeyedServiceProvider)
          .getKeyedServiceFromType(Iterable<T>, serviceKey);
      if (result is List<dynamic>) {
        return result.cast<T>();
      }
      return List<T>.empty();
    }
    throw InvalidOperationException(
      message: 'This service provider doesn\'t support keyed services.',
    );
  }

  /// Get an enumeration of services of type [serviceType] from
  /// the [ServiceProvider].
  ///
  /// This overload is not supported because Dart cannot construct
  /// `Iterable<T>` from a runtime [Type] value. Use
  /// [getKeyedServices] with a type argument instead.
  Iterable<Object> getKeyedServicesFromType(
    Type serviceType,
    Object? serviceKey,
  ) =>
      throw UnsupportedError(
        'getKeyedServicesFromType cannot construct Iterable<T> from a '
        'runtime Type. Use getKeyedServices<T>(serviceKey) instead.',
      );
}

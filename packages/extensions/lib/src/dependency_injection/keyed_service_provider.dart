import 'service_provider.dart';

/// KeyedServiceProvider is a service provider that can be used to
/// retrieve services using a key in addition to a type.
abstract class KeyedServiceProvider implements ServiceProvider {
  /// Gets the service object of the specified type.
  Object? getKeyedServiceFromType(Type serviceType, Object? serviceKey);

  /// Gets service of type [serviceType] from the [ServiceProvider]
  /// implementing this interface.
  Object getRequiredKeyedServiceFromType(Type serviceType, Object? serviceKey);

  // /// Gets services of type [T] from the [ServiceProvider].
  // Iterable<T> getKeyedServices<T>(Object? serviceKey);
}

/// Statics for use with [KeyedServiceProvider].
class KeyedService {
  /// Represents a key that matches any key.
  static Object get anyKey => AnyKeyObj();
}

class AnyKeyObj {
  @override
  String toString() => '*';
}

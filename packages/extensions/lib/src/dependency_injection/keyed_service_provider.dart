import 'service_provider.dart';

/// KeyedServiceProvider is a service provider that can be used to
/// retrieve services using a key in addition to a type.
///
/// Adapted from
abstract interface class KeyedServiceProvider implements ServiceProvider {
  /// Gets the service object of the specified type.
  Object? getKeyedServiceFromType(Type serviceType, Object? serviceKey);

  /// Gets service of type [serviceType] from the [ServiceProvider]
  /// implementing this interface.
  Object getRequiredKeyedServiceFromType(Type serviceType, Object? serviceKey);
}

/// Statics for use with [KeyedServiceProvider].
class KeyedService {
  /// Represents a key that matches any key.
  static Object get anyKey => _AnyKeyObj();
}

final class _AnyKeyObj {
  @override
  String toString() => '*';
}

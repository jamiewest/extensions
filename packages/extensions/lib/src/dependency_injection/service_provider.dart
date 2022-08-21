/// Defines a mechanism for retrieving a service object; that is, an object
/// that provides custom support to other objects.
abstract class ServiceProvider {
  // Gets the service object of the specified type.
  T? getService<T>();

  Iterable<T> getServices<T>();
}

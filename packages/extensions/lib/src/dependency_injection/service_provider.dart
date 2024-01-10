/// Defines a mechanism for retrieving a service object; that is, an object
/// that provides custom support to other objects.
abstract interface class ServiceProvider {
  // Gets the service object of the specified type.
  Object? getServiceFromType(Type type);
}

/// Defines a mechanism for retrieving a service object; that is, an object
/// that provides custom support to other objects.
///
/// [^1]:Adapted from the Microsoft .NET [`IServiceProvider`](https://learn.microsoft.com/en-us/dotnet/api/system.iserviceprovider) interface.
abstract interface class ServiceProvider {
  /// Gets the service object of the specified type.
  Object? getServiceFromType(Type type);
}

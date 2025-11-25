import 'service_collection.dart';

/// Specifies the lifetime of a service in a [ServiceCollection].
///
/// Adapted from [Microsoft.Extensions.DependencyInjection.ServiceLifetime](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.servicelifetime)
enum ServiceLifetime {
  /// Specifies that a single instance of the service will be created.
  singleton,

  /// Specifies that a new instance of the service will be created
  /// for each scope.
  scoped,

  /// Specifies that a new instance of the service will be created
  /// every time it is requested.
  transient,
}

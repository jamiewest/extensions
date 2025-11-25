import 'service_provider.dart';
import 'service_scope.dart';

/// A factory for creating instances of [ServiceScope],
/// which is used to create services within a scope.
///
/// Adapted from [Microsoft.Extensions.DependencyInjection.IServiceScopeFactory](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.iservicescopefactory)
abstract interface class ServiceScopeFactory {
  /// Create a [ServiceScope] which contains a [ServiceProvider]
  /// used to resolve dependencies from a newly created scope.
  ServiceScope createScope();
}

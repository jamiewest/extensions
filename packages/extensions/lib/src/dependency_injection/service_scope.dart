import '../system/disposable.dart';
import 'service_provider.dart';

/// The [dispose()] method ends the scope lifetime. Once dispose
/// is called, any scoped services that have been resolved from
/// [ServiceProvider] will be disposed.
///
/// Adapted from [Microsoft.Extensions.DependencyInjection.IServiceScope](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.iservicescope)
abstract interface class ServiceScope implements Disposable {
  /// The [ServiceProvider] used to resolve dependencies from the scope.
  ServiceProvider get serviceProvider;
}

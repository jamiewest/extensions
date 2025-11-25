import 'service_collection.dart';
import 'service_provider.dart';

/// Provides an extension point for creating a container
/// specific builder and a [ServiceProvider].
///
/// Adapted from [IServiceProviderFactory](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.iserviceproviderfactory-1)
/// located in the `Microsoft.Extensions.DependencyInjection` namespace.
abstract interface class ServiceProviderFactory<TContainerBuilder> {
  /// Creates a container builder from a [ServiceCollection].
  TContainerBuilder createBuilder(ServiceCollection services);

  /// Creates a [ServiceProvider] from the container builder.
  ServiceProvider createServiceProvider(TContainerBuilder containerBuilder);
}

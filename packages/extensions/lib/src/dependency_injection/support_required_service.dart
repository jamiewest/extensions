import 'service_provider.dart';

/// Optional contract used by
/// [ServiceProviderServiceExtensions.getRequiredService()] to resolve services
/// if supported by [ServiceProvider].
///
/// Adapted from [Microsoft.Extensions.DependencyInjection.ISupportRequiredService](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.isupportrequiredservice)
abstract interface class SupportRequiredService {
  /// Gets service of type [serviceType] from the [ServiceProvider]
  /// implementing this interface.
  Object getRequiredService(Type serviceType);
}

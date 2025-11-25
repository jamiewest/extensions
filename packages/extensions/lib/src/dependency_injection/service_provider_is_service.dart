import 'service_provider.dart';

/// Optional service used to determine if the specified type is available from
/// the [ServiceProvider].
///
/// Adapted from [Microsoft.Extensions.DependencyInjection.IServiceProviderIsService](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.iserviceproviderisservice)
abstract interface class ServiceProviderIsService {
  /// Determines if the specified service type is available from the
  /// [ServiceProvider].
  bool isService(Type serviceType);
}

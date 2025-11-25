import '../dependency_injection/service_collection.dart';
import '../dependency_injection/service_collection_descriptor_extensions.dart';
import '../dependency_injection/service_descriptor.dart';
import 'hosted_service.dart';

/// Extension methods for adding hosted services to a [ServiceCollection].
///
/// Adapted from [`Microsoft.Extensions.Hosting.Abstractions`](https://github.com/dotnet/runtime/blob/main/src/libraries/Microsoft.Extensions.Hosting.Abstractions/src/ServiceCollectionHostedServiceExtensions.cs)
extension ServiceCollectionHostedServiceExtensions on ServiceCollection {
  /// Add a [HostedService] registration for the given type.
  ServiceCollection addHostedService<THostedService extends HostedService>(
    ImplementationFactory implementationFactory,
  ) {
    tryAddIterable(
      ServiceDescriptor.singleton<HostedService>(
        implementationFactory,
      ),
    );

    return this;
  }
}

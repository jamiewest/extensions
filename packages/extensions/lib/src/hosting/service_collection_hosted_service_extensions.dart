import '../dependency_injection/service_collection.dart';
import '../dependency_injection/service_collection_descriptor_extensions.dart';
import '../dependency_injection/service_descriptor.dart';
import 'hosted_service.dart';

extension ServiceCollectionHostedServiceExtensions on ServiceCollection {
  /// Add an [HostedService] registration for the given type.
  ServiceCollection addHostedService<THostedService extends HostedService>(
    ImplementationFactory implementationFactory,
  ) {
    tryAddIterable(
      ServiceDescriptor.singletonInstance<THostedService>(
        implementationFactory,
      ),
    );

    return this;
  }
}

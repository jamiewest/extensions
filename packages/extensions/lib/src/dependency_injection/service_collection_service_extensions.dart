import 'service_collection.dart';
import 'service_descriptor.dart';

/// Extension methods for adding services to a [ServiceCollection].
extension ServiceCollectionServiceExtensions on ServiceCollection {
  ServiceCollection addTransient<TService, TImplementation>(
    ImplementationFactory<TImplementation> implementationFactory,
  ) {
    final descriptor = ServiceDescriptor.transient<TService, TImplementation>(
      implementationFactory,
    );
    add(descriptor);
    return this;
  }

  ServiceCollection addScoped<TService, TImplementation>(
    ImplementationFactory<TImplementation> implementationFactory,
  ) {
    var descriptor = ServiceDescriptor.scoped<TService, TImplementation>(
      implementationFactory,
    );
    add(descriptor);
    return this;
  }

  ServiceCollection addSingleton<TService, TImplementation>(
    ImplementationFactory<TImplementation> implementationFactory,
  ) {
    final descriptor = ServiceDescriptor.singleton<TService, TImplementation>(
      implementationFactory,
    );

    add(descriptor);
    return this;
  }
}

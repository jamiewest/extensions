import 'service_collection.dart';
import 'service_descriptor.dart';

/// Extension methods for adding services to a [ServiceCollection].
extension ServiceCollectionServiceExtensions on ServiceCollection {
  ServiceCollection addTransient<TService>(
    ImplementationFactory implementationFactory,
  ) {
    final descriptor = ServiceDescriptor.transient<TService>(
      implementationFactory,
    );
    add(descriptor);
    return this;
  }

  ServiceCollection addScoped<TService>(
    ImplementationFactory implementationFactory,
  ) {
    var descriptor = ServiceDescriptor.scoped<TService>(
      implementationFactory,
    );
    add(descriptor);
    return this;
  }

  ServiceCollection addSingleton<TService>(
    ImplementationFactory implementationFactory,
  ) {
    final descriptor = ServiceDescriptor.singleton<TService>(
      implementationFactory,
    );

    add(descriptor);
    return this;
  }

  ServiceCollection addSingletonInstance<TService>(
    Object implementationInstance,
  ) {
    final descriptor = ServiceDescriptor.singletonInstance<TService>(
      implementationInstance,
    );

    add(descriptor);
    return this;
  }
}

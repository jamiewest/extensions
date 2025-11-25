import 'service_collection.dart';
import 'service_descriptor.dart';

/// Extension methods for adding services to a [ServiceCollection].
extension ServiceCollectionServiceExtensions on ServiceCollection {
  /// Adds a transient service of the type specified in [TService] with
  /// a factory specified in [implementationFactory] to the specified
  /// [ServiceCollection].
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

  /// Adds a keyed transient service of the type specified in [TService]
  /// with a factory specified in [implementationFactory] to the specified
  /// [ServiceCollection].
  ServiceCollection addKeyedTransient<TService>(
    Object? serviceKey,
    KeyedImplementationFactory implementationFactory,
  ) {
    final descriptor = ServiceDescriptor.keyedTransient<TService>(
      serviceKey,
      (services) => implementationFactory,
    );
    add(descriptor);
    return this;
  }

  /// Adds a keyed scoped service of the type specified in [TService]
  /// with a factory specified in [implementationFactory] to the specified
  /// [ServiceCollection].
  ServiceCollection addKeyedScoped<TService>(
    Object? serviceKey,
    KeyedImplementationFactory implementationFactory,
  ) {
    final descriptor = ServiceDescriptor.keyedScoped<TService>(
      serviceKey,
      (services) => implementationFactory,
    );
    add(descriptor);
    return this;
  }

  /// Adds a keyed singleton service of the type specified in [TService]
  /// with a factory specified in [implementationFactory] to the specified
  /// [ServiceCollection].
  ServiceCollection addKeyedSingleton<TService>(
    Object? serviceKey,
    KeyedImplementationFactory implementationFactory,
  ) {
    final descriptor = ServiceDescriptor.keyedSingleton<TService>(
      serviceKey,
      (services) => implementationFactory,
    );
    add(descriptor);
    return this;
  }

  /// Adds a keyed singleton service of the type specified in [TService]
  /// with an instance specified in [implementationInstance] to the specified
  /// [ServiceCollection].
  ServiceCollection addKeyedSingletonInstance<TService>(
    Object? serviceKey,
    Object implementationInstance,
  ) {
    final descriptor = ServiceDescriptor.keyedSingletonInstance<TService>(
      serviceKey,
      implementationInstance,
    );
    add(descriptor);
    return this;
  }
}

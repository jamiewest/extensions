import 'service_collection.dart';
import 'service_descriptor.dart';
import 'service_lifetime.dart';

/// Extension methods for adding and removing services to an
/// [ServiceCollection].
extension ServiceCollectionDescriptorExtensions on ServiceCollection {
  /// Adds the specified [descriptor] to the list if the
  /// service type hasn't already been registered.
  void tryAdd(ServiceDescriptor descriptor) {
    final count = length;
    for (var i = 0; i < count; i++) {
      if (this[i].serviceType.hashCode == descriptor.serviceType.hashCode &&
          this[i].serviceKey == descriptor.serviceKey) {
        return;
      }
    }
    add(descriptor);
  }

  /// Adds the specified `TService` as a [ServiceLifetime.transient] service
  /// using the factory specified in [implementationFactory] to the `services`
  /// if the service type hasn't already been registered.
  void tryAddTransient<TService>(
    ImplementationFactory implementationFactory,
  ) {
    final descriptor = ServiceDescriptor.transient<TService>(
      implementationFactory,
    );
    tryAdd(descriptor);
  }

  /// Adds the specified `TService` as a [ServiceLifetime.scoped] service
  /// using the factory specified in [implementationFactory] to the `services`
  /// if the service type hasn't already been registered.
  void tryAddScoped<TService>(
    ImplementationFactory implementationFactory,
  ) {
    final descriptor = ServiceDescriptor.scoped<TService>(
      implementationFactory,
    );
    tryAdd(descriptor);
  }

  /// Adds the specified `TService` as a [ServiceLifetime.singleton] service
  /// using the factory specified in `implementationFactory` to the `services`
  /// if the service type hasn't already been registered.
  void tryAddSingleton<TService>(
    ImplementationFactory implementationFactory,
  ) {
    final descriptor = ServiceDescriptor.singleton<TService>(
      implementationFactory,
    );

    tryAdd(descriptor);
  }

  void tryAddSingletonInstance<TService>(
    Object implementationInstance,
  ) {
    final descriptor = ServiceDescriptor.singletonInstance<TService>(
      implementationInstance,
    );

    tryAdd(descriptor);
  }

  void tryAddKeyedSingletonInstance<TService>(
    Object? serviceKey,
    Object implementationInstance,
  ) {
    final descriptor = ServiceDescriptor.keyedSingletonInstance<TService>(
      serviceKey,
      implementationInstance,
    );

    tryAdd(descriptor);
  }

  /// Adds a [ServiceDescriptor] if an existing descriptor with the same
  /// [ServiceDescriptor.serviceType] and an implementation that does not
  /// already exist in `services`.
  ///
  /// This matches .NET's TryAddEnumerable behavior: it only prevents adding
  /// duplicate descriptors (same type, lifetime, implementation, and key).
  /// Multiple services of the same type with different implementations are
  /// allowed.
  void tryAddIterable(ServiceDescriptor descriptor) {
    var count = length;
    for (var i = 0; i < count; i++) {
      var existing = this[i];

      // Check if the exact same descriptor already exists
      // This uses ServiceDescriptor's equality operator which compares
      // service type, lifetime, implementation (factory/instance), and key
      if (existing == descriptor) {
        // Exact duplicate found, don't add
        return;
      }
    }

    // No duplicate found, safe to add
    add(descriptor);
  }

  void tryAddKeyedTransient<TService>(
    Object? serviceKey,
    KeyedImplementationFactory implementationFactory,
  ) {
    var descriptor = ServiceDescriptor.keyedTransient<TService>(
      serviceKey,
      implementationFactory,
    );
    tryAdd(descriptor);
  }

  void tryAddKeyedScoped<TService>(
    Object? serviceKey,
    KeyedImplementationFactory implementationFactory,
  ) {
    var descriptor = ServiceDescriptor.keyedScoped<TService>(
      serviceKey,
      implementationFactory,
    );
    tryAdd(descriptor);
  }

  /// Adds the specified `TService` as a [ServiceLifetime.singleton] service
  /// with the specified [serviceKey] using the factory specified in
  /// [implementationFactory] to the `services` if the service type hasn't
  /// already been registered with that key.
  void tryAddKeyedSingleton<TService>(
    Object? serviceKey,
    KeyedImplementationFactory implementationFactory,
  ) {
    var descriptor = ServiceDescriptor.keyedSingleton<TService>(
      serviceKey,
      implementationFactory,
    );
    tryAdd(descriptor);
  }

  /// Removes the first service in [ServiceCollection] with the same service
  /// type as [descriptor] and adds [descriptor] to the collection.
  ServiceCollection replace(ServiceDescriptor descriptor) {
    // Remove existing
    var count = length;
    for (var i = 0; i < count; i++) {
      if (this[i].serviceType == descriptor.serviceType) {
        removeAt(i);
        break;
      }
    }
    add(descriptor);
    return this;
  }

  /// Removes all services of type [serviceType] in [ServiceCollection].
  ServiceCollection removeAll(Type serviceType) {
    for (var i = length - 1; i >= 0; i--) {
      var descriptor = this[i];
      if (descriptor.serviceType == serviceType) {
        removeAt(i);
      }
    }
    return this;
  }

  /// Removes all services of type [serviceType] in [ServiceCollection].
  ServiceCollection removeAllKeyed(Type serviceType, Object? serviceKey) {
    for (var i = length - 1; i >= 0; i--) {
      var descriptor = this[i];
      if (descriptor.serviceType == serviceType &&
          descriptor.serviceKey == serviceKey) {
        removeAt(i);
      }
    }
    return this;
  }
}

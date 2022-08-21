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
      if (this[i].serviceType.hashCode == descriptor.serviceType.hashCode) {
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
    final descriptor = ServiceDescriptor.singletonInstance(
      implementationInstance,
    );

    tryAdd(descriptor);
  }

  /// Adds a [ServiceDescriptor] if an existing descriptor with the same
  /// [ServiceDescriptor.serviceType] and an implementation that does not
  /// already exist in `services`.
  void tryAddIterable(ServiceDescriptor descriptor) {
    var count = length;
    for (var i = 0; i < count; i++) {
      // var service = this[i];
      //if (service.serviceType.hashCode == descriptor.serviceType.hashCode &&
      //  service.implementationType == descriptor.implementationType) {
      // Already added
      //return;
    }

    add(descriptor);
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
}

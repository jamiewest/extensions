import 'service_collection.dart';
import 'service_descriptor.dart';
import 'service_lifetime.dart';

/// Extension methods for adding and removing services to an
/// [ServiceCollection].
extension ServiceCollectionDescriptorExtensions on ServiceCollection {
  /// Adds the specified [descriptor] to the list if the
  /// service type hasn't already been registered.
  void tryAdd(ServiceDescriptor descriptor) {
    var count = length;
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
    ImplementationFactory<TService> implementationFactory,
  ) {
    var descriptor = ServiceDescriptor.transient<TService>(
      implementationFactory: implementationFactory,
    );
    tryAdd(descriptor);
  }

  /// Adds the specified `TService` as a [ServiceLifetime.scoped] service
  /// using the factory specified in [implementationFactory] to the `services`
  /// if the service type hasn't already been registered.
  void tryAddScoped<TService>(
    ImplementationFactory<TService> implementationFactory,
  ) {
    var descriptor = ServiceDescriptor.scoped<TService>(
      implementationFactory: implementationFactory,
    );
    tryAdd(descriptor);
  }

  /// Adds the specified `TService` as a [ServiceLifetime.singleton] service
  /// using the factory specified in `implementationFactory` to the `services`
  /// if the service type hasn't already been registered.
  void tryAddSingleton<TService>(
    TService? implementationInstance,
    ImplementationFactory<TService>? implementationFactory,
  ) {
    var descriptor = ServiceDescriptor.singleton<TService>(
      instance: implementationInstance,
      implementationFactory: implementationFactory,
    );
    tryAdd(descriptor);
  }

  /// Adds a [ServiceDescriptor] if an existing descriptor with the same
  /// [ServiceDescriptor.serviceType] and an implementation that does not
  /// already exist in `services`.
  void tryAddIterable(ServiceDescriptor descriptor) {
    var implementationType = descriptor.getImplementationType();
    if (implementationType == Object ||
        implementationType == descriptor.serviceType) {
      throw Exception('SR.TryAddIndistinguishableTypeToIterable');
    }

    var count = length;
    for (var i = 0; i < count; i++) {
      var service = this[i];
      if (service.serviceType == descriptor.serviceType &&
          service.getImplementationType() == implementationType) {
        // Already added
        return;
      }
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

import 'service_collection.dart';
import 'service_descriptor.dart';
import 'service_lifetime.dart';

/// Extension methods for adding services to a [ServiceCollection].
extension ServiceCollectionServiceExtensions on ServiceCollection {
  /// Adds a transient service of the type specified in [TService] with a
  /// factory specified in [implementationFactory] to the
  /// specified [ServiceCollection].
  ServiceCollection addTransient<TService>({
    required ImplementationFactory<TService> implementationFactory,
    Type? implementationType,
  }) {
    var descriptor = ServiceDescriptor(
      serviceType: TService,
      lifetime: ServiceLifetime.transient,
      factory: implementationFactory,
      implementationType: implementationType,
    );
    add(descriptor);
    return this;
  }

  /// Adds a scoped service of the type specified in [TService] with a with an
  /// implementation of the type  specified in [implementationType] to the
  /// specified [ServiceCollection].
  ServiceCollection addScoped<TService>({
    required ImplementationFactory<TService> implementationFactory,
    Type? implementationType,
  }) {
    var descriptor = ServiceDescriptor(
      serviceType: TService,
      lifetime: ServiceLifetime.scoped,
      factory: implementationFactory,
    );
    add(descriptor);
    return this;
  }

  /// Adds a singleton service of the type specified in [TService] with an
  /// implementation of the type specified in [implementationType] to the
  /// specified [ServiceCollection].
  ServiceCollection addSingleton<TService>({
    ImplementationFactory<TService>? implementationFactory,
    Object? implementationInstance,
    Type? implementationType,
  }) {
    ServiceDescriptor descriptor;
    if (implementationFactory != null) {
      descriptor = ServiceDescriptor(
        serviceType: TService,
        factory: implementationFactory,
      );
    } else {
      descriptor = ServiceDescriptor(
        serviceType: TService,
        instance: implementationInstance,
      );
    }

    add(descriptor);
    return this;
  }
}

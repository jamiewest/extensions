import '../system/exceptions/invalid_operation_exception.dart';

import 'service_lifetime.dart';
import 'service_provider.dart';

/// A factory to create new instances of the service implementation.
typedef ImplementationFactory = Object Function(
  ServiceProvider services,
);

typedef TypedImplementationFactory<T> = T Function(
  ServiceProvider services,
);

typedef KeyedImplementationFactory = Object Function(
  ServiceProvider services,
  Object? serviceKey,
);

typedef TypedKeyedImplementationFactory<T> = T Function(
  ServiceProvider services,
  Object? serviceKey,
);

/// Describes a service with its service type, implementation, and lifetime.
///
/// Adapted from [ServiceDescriptor.cs](https://github.com/dotnet/runtime/blob/main/src/libraries/Microsoft.Extensions.DependencyInjection.Abstractions/src/ServiceDescriptor.cs)
class ServiceDescriptor {
  final Object? _implementationInstance;
  final Object? _implementationFactory;

  ServiceDescriptor({
    required this.serviceType,
    this.lifetime = ServiceLifetime.singleton,
    this.serviceKey,
    Object? implementationInstance,
    Object? implementationFactory,
  })  : _implementationInstance = implementationInstance,
        _implementationFactory = implementationFactory;

  /// Initializes a new instance of [ServiceDescriptor] with the specified
  /// [instance] and default [ServiceLifetime].
  factory ServiceDescriptor._instance({
    required Type serviceType,
    required Object instance,
    Object? serviceKey,
  }) =>
      ServiceDescriptor(
        serviceType: serviceType,
        serviceKey: serviceKey,
        implementationInstance: instance,
      );

  /// Initializes a new instance of [ServiceDescriptor] with the specified
  /// instance.
  factory ServiceDescriptor._factory({
    required Type serviceType,
    Object? serviceKey,
    required Object factory,
    required ServiceLifetime lifetime,
  }) =>
      ServiceDescriptor(
        serviceType: serviceType,
        lifetime: lifetime,
        serviceKey: serviceKey,
        implementationFactory: factory,
      );

  /// Gets the [ServiceLifetime] of the service.
  final ServiceLifetime lifetime;

  /// Get the key of the service, if applicable.
  final Object? serviceKey;

  /// Gets the [Type] of the service.
  final Type serviceType;

  /// Gets the instance that implements the service.
  Object? get implementationInstance {
    if (isKeyedService) {
      throwKeyedDescriptor();
    }
    return _implementationInstance;
  }

  /// Gets the instance that implements the service.
  Object? get keyedImplementationInstance {
    if (!isKeyedService) {
      throwNonKeyedDescriptor();
    }

    return _implementationInstance;
  }

  /// Gets the factory used for creating service instances.
  ImplementationFactory? get implementationFactory {
    if (isKeyedService) {
      throwKeyedDescriptor();
    }
    return _implementationFactory as ImplementationFactory;
  }

  /// Gets the factory used for creating service instances.
  KeyedImplementationFactory? get keyedImplementationFactory {
    if (!isKeyedService) {
      throwKeyedDescriptor();
    }
    return _implementationFactory as KeyedImplementationFactory;
  }

  @override
  String toString() {
    String lifetimeText = '''ServiceType: ${serviceType.toString()} 
        Lifetime: ${lifetime.toString()} ''';

    if (isKeyedService) {
      lifetimeText += 'ServiceKey: $serviceKey ';

      if (keyedImplementationFactory != null) {
        return '${lifetimeText}KeyedImplementationFactory: '
            '$keyedImplementationFactory';
      }

      return '${lifetimeText}KeyedImplementationInstance: '
          '$keyedImplementationInstance';
    } else {
      if (implementationFactory != null) {
        return '${lifetimeText}ImplementationFactory: $implementationFactory';
      }

      return '${lifetimeText}ImplementationInstance: $implementationInstance';
    }
  }

  /// Creates an instance of [ServiceDescriptor] with the specified
  /// [TService], [implementationFactory] and the [ServiceLifetime.transient].
  static ServiceDescriptor transient<TService>(
    ImplementationFactory implementationFactory,
  ) =>
      ServiceDescriptor._factory(
        serviceType: TService,
        factory: implementationFactory,
        lifetime: ServiceLifetime.transient,
      );

  /// Creates an instance of [ServiceDescriptor] with the specified
  /// [TService], and the [ServiceLifetime.transient] lifetime.
  static ServiceDescriptor keyedTransient<TService>(
    Object? serviceKey,
    ImplementationFactory implementationFactory,
  ) =>
      ServiceDescriptor._factory(
        serviceType: TService,
        serviceKey: serviceKey,
        factory: implementationFactory,
        lifetime: ServiceLifetime.transient,
      );

  /// Creates an instance of [ServiceDescriptor] with the specified
  /// [TService], [implementationFactory] and the [ServiceLifetime.scoped].
  static ServiceDescriptor scoped<TService>(
    ImplementationFactory implementationFactory,
  ) =>
      ServiceDescriptor._factory(
        serviceType: TService,
        factory: implementationFactory,
        lifetime: ServiceLifetime.scoped,
      );

  /// Creates an instance of [ServiceDescriptor] with the specified
  /// [TService], [implementationFactory] and the [ServiceLifetime.scoped].
  static ServiceDescriptor keyedScoped<TService>(
    Object? serviceKey,
    ImplementationFactory implementationFactory,
  ) =>
      ServiceDescriptor._factory(
        serviceType: TService,
        serviceKey: serviceKey,
        factory: implementationFactory,
        lifetime: ServiceLifetime.scoped,
      );

  /// Creates an instance of [ServiceDescriptor] with the specified
  /// [TService], [implementationFactory] and the [ServiceLifetime.singleton].
  static ServiceDescriptor singleton<TService>(
    ImplementationFactory implementationFactory,
  ) =>
      ServiceDescriptor._factory(
        serviceType: TService,
        factory: implementationFactory,
        lifetime: ServiceLifetime.singleton,
      );

  /// Creates an instance of [ServiceDescriptor] with the specified
  /// [TService], [serviceKey], [implementationFactory]
  /// and the [ServiceLifetime.singleton] lifetime.
  static ServiceDescriptor keyedSingleton<TService>(
    Object? serviceKey,
    ImplementationFactory implementationFactory,
  ) =>
      ServiceDescriptor._factory(
        serviceType: TService,
        serviceKey: serviceKey,
        factory: implementationFactory,
        lifetime: ServiceLifetime.singleton,
      );

  static ServiceDescriptor singletonInstance<TService>(
    Object implementationInstance,
  ) =>
      ServiceDescriptor._instance(
        serviceType: TService,
        instance: implementationInstance,
      );

  /// Creates an instance of [ServiceDescriptor] with the specified
  /// [serviceKey], [implementationInstance],
  /// and the [ServiceLifetime.singleton] lifetime.
  static ServiceDescriptor keyedSingletonInstance<TService>(
    Object? serviceKey,
    Object implementationInstance,
  ) =>
      ServiceDescriptor._instance(
        serviceType: TService,
        serviceKey: serviceKey,
        instance: implementationInstance,
      );

  /// Indicates whether the service is a keyed service.
  bool get isKeyedService => serviceKey != null;

  void throwKeyedDescriptor() {
    throw InvalidOperationException(
      message: 'This service descriptor is keyed. '
          'Your service provider may not support keyed services.',
    );
  }

  void throwNonKeyedDescriptor() {
    throw InvalidOperationException(
      message: 'This service descriptor is not keyed.',
    );
  }

  /// Equality comparison based on service type, lifetime, implementation
  /// type/instance/factory, and service key.
  ///
  /// This matches .NET's ServiceDescriptor.Equals behavior where two
  /// descriptors are equal if they describe the same service registration.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! ServiceDescriptor) {
      return false;
    }

    // Service type and lifetime must match
    if (serviceType != other.serviceType || lifetime != other.lifetime) {
      return false;
    }

    // Service key must match (including null == null)
    if (serviceKey != other.serviceKey) {
      return false;
    }

    // For instance-based descriptors, compare instances
    if (_implementationInstance != null ||
        other._implementationInstance != null) {
      return identical(
        _implementationInstance,
        other._implementationInstance,
      );
    }

    // For factory-based descriptors, compare factories by identity
    if (_implementationFactory != null ||
        other._implementationFactory != null) {
      return identical(
        _implementationFactory,
        other._implementationFactory,
      );
    }

    // Both are null
    return true;
  }

  @override
  int get hashCode => Object.hash(
        serviceType,
        lifetime,
        serviceKey,
        _implementationInstance != null
            ? identityHashCode(_implementationInstance)
            : 0,
        _implementationFactory != null
            ? identityHashCode(_implementationFactory)
            : 0,
      );
}

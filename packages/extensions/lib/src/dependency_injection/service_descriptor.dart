import '../common/exceptions/invalid_operation_exception.dart';

import 'service_lifetime.dart';
import 'service_lookup/factory_call_site.dart';
import 'service_provider.dart';

typedef ImplementationFactory = Object Function(
  ServiceProvider services,
);

typedef KeyedImplementationFactory = Object Function(
  ServiceProvider services,
  Object? serviceKey,
);

/// Describes a service with its service type, implementation, and lifetime.
class ServiceDescriptor {
  Object? _implementationInstance;
  Object? _implementationFactory;

  ServiceDescriptor._({
    required this.serviceType,
    required this.lifetime,
    this.serviceKey,
  });

  /// Initializes a new instance of [ServiceDescriptor] with the specified
  /// [instance] and default [ServiceLifetime].
  factory ServiceDescriptor._instance({
    required Type serviceType,
    required Object instance,
    Object? serviceKey,
  }) =>
      ServiceDescriptor._(
        serviceType: serviceType,
        serviceKey: serviceKey,
        lifetime: ServiceLifetime.singleton,
      ).._implementationInstance = instance;

  factory ServiceDescriptor._factory({
    required Type serviceType,
    Object? serviceKey,
    required Object factory,
    required ServiceLifetime lifetime,
  }) =>
      ServiceDescriptor._(
        serviceType: serviceType,
        lifetime: lifetime,
        serviceKey: serviceKey,
      ).._implementationFactory = factory;

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
    String? newlifetime = '''ServiceType: ${serviceType.toString()} 
        Lifetime: ${lifetime.toString()} ''';

    if (implementationFactory != null) {
      return '''${newlifetime}ImplementationFactory: 
      ${implementationFactory?.toString()}''';
    }

    return '''${newlifetime}ImplementationInstance: 
    ${implementationInstance.toString()}''';
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
}

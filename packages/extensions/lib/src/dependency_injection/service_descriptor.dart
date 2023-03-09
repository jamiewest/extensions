import 'service_lifetime.dart';
import 'service_lookup/factory_call_site.dart';
import 'service_provider.dart';

typedef ImplementationFactory = Object Function(
  ServiceProvider services,
);

/// Describes a service with its service type, implementation, and lifetime.
class ServiceDescriptor {
  Object? _implementationInstance;
  FactoryCallback? _implementationFactory;

  ServiceDescriptor(
    this.serviceType,
    this.lifetime,
  );

  /// Initializes a new instance of [ServiceDescriptor] with the specified
  /// [instance] and default [ServiceLifetime].
  factory ServiceDescriptor._instance(
    Type serviceType,
    Object instance,
  ) =>
      ServiceDescriptor(
        serviceType,
        ServiceLifetime.singleton,
      ).._implementationInstance = instance;

  factory ServiceDescriptor._factory(
    Type serviceType,
    FactoryCallback factory,
    ServiceLifetime lifetime,
  ) =>
      ServiceDescriptor(
        serviceType,
        lifetime,
      ).._implementationFactory = factory;

  final ServiceLifetime lifetime;

  final Type serviceType;

  Object? get implementationInstance => _implementationInstance;

  FactoryCallback? get implementationFactory => _implementationFactory;

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
        TService,
        implementationFactory,
        ServiceLifetime.transient,
      );

  /// Creates an instance of [ServiceDescriptor] with the specified
  /// [TService], [implementationFactory] and the [ServiceLifetime.scoped].
  static ServiceDescriptor scoped<TService>(
    ImplementationFactory implementationFactory,
  ) =>
      ServiceDescriptor._factory(
        TService,
        implementationFactory,
        ServiceLifetime.scoped,
      );

  /// Creates an instance of [ServiceDescriptor] with the specified
  /// [TService], [implementationFactory] and the [ServiceLifetime.singleton].
  static ServiceDescriptor singleton<TService>(
    ImplementationFactory implementationFactory,
  ) =>
      ServiceDescriptor._factory(
        TService,
        implementationFactory,
        ServiceLifetime.singleton,
      );

  static ServiceDescriptor singletonInstance<TService>(
    Object implementationInstance,
  ) =>
      ServiceDescriptor._instance(
        TService,
        implementationInstance,
      );
}

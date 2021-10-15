import 'service_lifetime.dart';
import 'service_provider.dart';

typedef ImplementationFactory<TService> = TService Function(
  ServiceProvider services,
);

/// Describes a service with its service type, implementation, and lifetime.
class ServiceDescriptor {
  final Object? _implementationInstance;
  final ImplementationFactory? _implementationFactory;
  final Type? _implementationType;

  /// Initializes a new instance of [ServiceDescriptor] with the specified
  /// [implementationType].
  ServiceDescriptor({
    required this.serviceType,
    this.lifetime = ServiceLifetime.singleton,
    Object? instance,
    ImplementationFactory? factory,
    Type? implementationType,
  })  : _implementationInstance = instance,
        _implementationFactory = factory,
        _implementationType = implementationType;

  /// Creates an instance of [ServiceDescriptor] with the specified
  /// [TService], [implementationFactory] and the [ServiceLifetime.transient].
  static ServiceDescriptor transient<TService>({
    required ImplementationFactory<TService> implementationFactory,
    Type? implementationType,
  }) =>
      describe<TService>(
        lifetime: ServiceLifetime.transient,
        implementationFactory: implementationFactory,
        implementationType: implementationType,
      );

  /// Creates an instance of [ServiceDescriptor] with the specified
  /// [TService], [implementationFactory], and the [ServiceLifetime.scoped]
  /// lifetime.
  static ServiceDescriptor scoped<TService>({
    required ImplementationFactory<TService> implementationFactory,
    Type? implementationType,
  }) =>
      describe<TService>(
        lifetime: ServiceLifetime.scoped,
        implementationFactory: implementationFactory,
        implementationType: implementationType,
      );

  /// Creates an instance of [ServiceDescriptor] with the specified [TService],
  /// [implementationInstance], and the `ServiceLifetime.singleton` lifetime.
  static ServiceDescriptor singleton<TService>({
    TService? instance,
    ImplementationFactory<TService>? implementationFactory,
    Type? implementationType,
  }) =>
      describe<TService>(
        implementationInstance: instance,
        implementationFactory: implementationFactory,
        implementationType: implementationType,
      );

  /// Creates an instance of [ServiceDescriptor].
  static ServiceDescriptor describe<TService>({
    TService? implementationInstance,
    ImplementationFactory<TService>? implementationFactory,
    Type? implementationType,
    ServiceLifetime lifetime = ServiceLifetime.singleton,
  }) =>
      ServiceDescriptor(
        serviceType: TService,
        instance: implementationInstance,
        factory: implementationFactory,
        lifetime: lifetime,
        implementationType: implementationType,
      );

  final ServiceLifetime lifetime;

  final Type serviceType;

  Type? get implementationType => _implementationType;

  Object? get implementationInstance => _implementationInstance;

  ImplementationFactory? get implementationFactory => _implementationFactory;

  @override
  String toString() {
    String? _lifetime =
        // ignore: lines_longer_than_80_chars
        'ServiceType: ${serviceType.toString()} Lifetime: ${lifetime.toString()} ';

    if (implementationType != null) {
      // ignore: lines_longer_than_80_chars
      return '${_lifetime}ImplementationType: ${implementationType.toString()}';
    }

    if (implementationFactory != null) {
      // ignore: lines_longer_than_80_chars
      return '${_lifetime}ImplementationFactory: ${implementationFactory?.toString()}';
    }

    // ignore: lines_longer_than_80_chars
    return '${_lifetime}ImplementationInstance: ${implementationInstance.toString()}';
  }

  Type? getImplementationType() {
    if (implementationType != null) {
      return implementationType!;
    } else if (implementationInstance != null) {
      return implementationType.runtimeType;
    } else if (implementationFactory != null) {
      return implementationFactory.runtimeType;
    }
    assert(false, '''
ImplementationType, ImplementationInstance or ImplementationFactory must be non null''');
    return null;
  }
}

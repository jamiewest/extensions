import '../../dependency_injection/service_collection.dart';
import '../../dependency_injection/service_provider.dart';
import '../../dependency_injection/service_provider_factory.dart';
import '../host_builder_context.dart';

typedef ContextResolver = HostBuilderContext? Function();

typedef FactoryResolver<TContainerBuilder>
    = ServiceProviderFactory<TContainerBuilder> Function(
  HostBuilderContext hostContext,
);

abstract class IServiceFactoryAdapter {
  Object createBuilder(ServiceCollection services);

  ServiceProvider createServiceProvider(Object containerBuilder);
}

class ServiceFactoryAdapter<TContainerBuilder>
    implements IServiceFactoryAdapter {
  ServiceProviderFactory<TContainerBuilder>? _serviceProviderFactory;
  ContextResolver? _contextResolver;
  FactoryResolver<TContainerBuilder>? _factoryResolver;

  ServiceFactoryAdapter._({
    ServiceProviderFactory<TContainerBuilder>? serviceProviderFactory,
    ContextResolver? contextResolver,
    FactoryResolver<TContainerBuilder>? factoryResolver,
  })  : _serviceProviderFactory = serviceProviderFactory,
        _contextResolver = contextResolver,
        _factoryResolver = factoryResolver;

  ServiceFactoryAdapter(
    ServiceProviderFactory<TContainerBuilder> serviceProviderFactory,
  ) : _serviceProviderFactory = serviceProviderFactory;

  factory ServiceFactoryAdapter.builder(
    ContextResolver contextResolver,
    FactoryResolver<TContainerBuilder> factoryResolver,
  ) =>
      ServiceFactoryAdapter._(
        contextResolver: contextResolver,
        factoryResolver: factoryResolver,
      );

  @override
  Object createBuilder(ServiceCollection services) {
    if (_serviceProviderFactory == null) {
      assert(_factoryResolver != null && _contextResolver != null);
      _serviceProviderFactory =
          _factoryResolver!(_contextResolver!() as HostBuilderContext);

      if (_serviceProviderFactory == null) {
        throw Exception(
          'The resolver returned a null ServiceProviderFactory',
        );
      }
    }

    return _serviceProviderFactory?.createBuilder(services) as Object;
  }

  @override
  ServiceProvider createServiceProvider(Object containerBuilder) {
    if (_serviceProviderFactory == null) {
      throw Exception(
        'CreateBuilder must be called before CreateServiceProvider',
      );
    }

    return _serviceProviderFactory!.createServiceProvider(
      containerBuilder as TContainerBuilder,
    );
  }
}

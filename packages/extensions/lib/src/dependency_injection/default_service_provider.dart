import 'package:extensions/src/dependency_injection/service_lookup/call_site_factory.dart';
import 'package:extensions/src/dependency_injection/service_lookup/call_site_validator.dart';
import 'package:extensions/src/dependency_injection/service_lookup/service_call_site.dart';
import 'package:extensions/src/dependency_injection/service_lookup/service_identifier.dart';

import '../common/async_disposable.dart';
import '../common/disposable.dart';
import 'keyed_service_provider.dart';
import 'service_descriptor.dart';
import 'service_lookup/call_site_chain.dart';
import 'service_lookup/runtime_service_provider_engine.dart';
import 'service_lookup/service_provider_engine.dart';
import 'service_lookup/service_provider_engine_scope.dart';
import 'service_provider.dart';
import 'service_provider_options.dart';

/// The default [ServiceProvider]
class DefaultServiceProvider
    implements
        ServiceProvider,
        KeyedServiceProvider,
        Disposable,
        AsyncDisposable {
  CallSiteValidator? _callSiteValidator;
  late final ServiceAccessor Function(ServiceIdentifier serviceIdentifier)
      _createServiceAccessor;
  late final ServiceProviderEngine _engine;
  bool _disposed = false;
  Map<ServiceIdentifier, ServiceAccessor> _serviceAccessors;

  final CallSiteFactory _callSiteFactory;

  late final ServiceProviderEngineScope _root;

  DefaultServiceProvider(
    List<ServiceDescriptor> serviceDescriptors,
    ServiceProviderOptions options,
  ) {
    // note that Root needs to be set before calling GetEngine(), because
    // the engine may need to access Root
    _root = ServiceProviderEngineScope(this, isRootScope: true);
    _engine = getEngine();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Future<void> disposeAsync() {
    // TODO: implement disposeAsync
    throw UnimplementedError();
  }

  @override
  T? getKeyedService<T>(Type serviceType) {
    // TODO: implement getKeyedService
    throw UnimplementedError();
  }

  @override
  Iterable<T> getKeyedServices<T>(Object? serviceKey) {
    // TODO: implement getKeyedServices
    throw UnimplementedError();
  }

  @override
  T getRequiredKeyedService<T>(Type serviceType) {
    // TODO: implement getRequiredKeyedService
    throw UnimplementedError();
  }

  @override
  T? getService<T>() {
    // TODO: implement getService
    throw UnimplementedError();
  }

  @override
  Iterable<T> getServices<T>() {
    // TODO: implement getServices
    throw UnimplementedError();
  }

  //   private ServiceAccessor CreateServiceAccessor(ServiceIdentifier serviceIdentifier)
  // {
  //     ServiceCallSite? callSite = CallSiteFactory.GetCallSite(serviceIdentifier, new CallSiteChain());
  //     if (callSite != null)
  //     {
  //         DependencyInjectionEventSource.Log.CallSiteBuilt(this, serviceIdentifier.ServiceType, callSite);
  //         OnCreate(callSite);

  //         // Optimize singleton case
  //         if (callSite.Cache.Location == CallSiteResultCacheLocation.Root)
  //         {
  //             object? value = CallSiteRuntimeResolver.Instance.Resolve(callSite, Root);
  //             return new ServiceAccessor { CallSite = callSite, RealizedService = scope => value };
  //         }

  //         Func<ServiceProviderEngineScope, object?> realizedService = _engine.RealizeService(callSite);
  //         return new ServiceAccessor { CallSite = callSite, RealizedService = realizedService };
  //     }
  //     return new ServiceAccessor { CallSite = callSite, RealizedService = _ => null };
  // }

  ServiceAccessor createServiceAccessor(ServiceIdentifier serviceIdentifier) {
    var callSite = _callSiteFactory.getCallSite(
      serviceIdentifier,
      CallSiteChain(),
    );
  }

  ServiceProviderEngine getEngine() {
    return RuntimeServiceProviderEngine();
  }
}

sealed class ServiceAccessor {
  ServiceCallSite? callSite;
  Object? Function(ServiceProviderEngineScope scope)? realizedService;
}

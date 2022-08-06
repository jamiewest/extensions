import '../primitives/async_disposable.dart';
import '../primitives/disposable.dart';
import 'service_descriptor.dart';
import 'service_lookup/call_site_chain.dart';
import 'service_lookup/call_site_factory.dart';
import 'service_lookup/call_site_result_cache_location.dart';
import 'service_lookup/call_site_runtime_resolver.dart';
import 'service_lookup/call_site_validator.dart';
import 'service_lookup/constant_call_site.dart';
import 'service_lookup/runtime_service_provider_engine.dart';
import 'service_lookup/service_call_site.dart';
import 'service_lookup/service_provider_call_site.dart';
import 'service_lookup/service_provider_engine.dart';
import 'service_lookup/service_provider_engine_scope.dart';
import 'service_lookup/service_scope_factory_call_site.dart';
import 'service_provider.dart';
import 'service_provider_is_service.dart';
import 'service_provider_options.dart';
import 'service_scope.dart';
import 'service_scope_factory.dart';

typedef CreateServiceAccessor = CreateServiceAccessorInner? Function(
  Type type,
);

typedef CreateServiceAccessorInner = Object? Function(
  ServiceProviderEngineScope scope,
);

class ServiceProviderImpl
    implements ServiceProvider, Disposable, AsyncDisposable {
  CallSiteValidator? _callSiteValidator;
  CreateServiceAccessor? _createServiceAccessor;
  // Internal for testing
  final ServiceProviderEngine _engine;
  bool _disposed;
  final Map<Type, CreateServiceAccessorInner?> _realizedServices;
  final CallSiteFactory _callSiteFactory;
  late final ServiceProviderEngineScope _root;

  // Internal constructor.
  ServiceProviderImpl(
    Iterable<ServiceDescriptor> serviceDescriptors,
    ServiceProviderOptions options,
  )   : _engine = RuntimeServiceProviderEngine(),
        _realizedServices = <Type, CreateServiceAccessorInner?>{},
        _disposed = false,
        _callSiteFactory = CallSiteFactory(serviceDescriptors) {
    _createServiceAccessor = (serviceType) {
      var callSite = _callSiteFactory.getCallSiteFromType(
        serviceType,
        CallSiteChain(),
      );
      if (callSite != null) {
        _onCreate(callSite);

        // Optimize singleton case
        if (callSite.cache.location == CallSiteResultCacheLocation.root) {
          var value = CallSiteRuntimeResolver.instance.resolve(callSite, _root);
          return (scope) => value;
        }

        return _engine.realizeService(callSite);
      }
      return (_) => null;
    };
    _root = ServiceProviderEngineScope(this, isRootScope: true);

    _callSiteFactory
      ..add(ServiceProvider, ServiceProviderCallSite())
      ..add(ServiceScopeFactory, ServiceScopeFactoryCallSite(_root))
      ..add(ServiceProviderIsService,
          ConstantCallSite(ServiceProviderIsService, _callSiteFactory));

    if (options.validateScopes) {
      _callSiteValidator = CallSiteValidator();
    }

    if (options.validateOnBuild) {
      var exceptions = <Exception>[];
      for (var serviceDescriptor in serviceDescriptors) {
        try {
          _validateService(serviceDescriptor);
        } catch (e) {
          exceptions.add(e as Exception);
        }
      }

      if (exceptions.isNotEmpty) {
        throw Exception('Some services are not able to be constructed');
      }
    }
  }

  CallSiteFactory get callSiteFactory => _callSiteFactory;

  ServiceProviderEngineScope get root => _root;

  void _validateService(ServiceDescriptor descriptor) {
    try {
      var callSite = _callSiteFactory.getCallSite(descriptor, CallSiteChain());
      if (callSite != null) {
        _onCreate(callSite);
      }
    } on Exception catch (e) {
      throw Exception(
          'Error while validating the service descriptor \'${descriptor.toString()}\': ${e.toString()}');
    }
  }

  ServiceScope createScope() {
    if (_disposed) {
      throw Exception('Disposed Exception');
    }
    return ServiceProviderEngineScope(this, isRootScope: false);
  }

  /// Gets the service object of the specified type.
  @override
  Object? getService<T>([ServiceScope? scope]) => _getService<T>(
        scope == null ? _root : scope as ServiceProviderEngineScope,
      );

  Object? _getService<T>(
      covariant ServiceProviderEngineScope serviceProviderEngineScope) {
    if (_disposed) {
      throw Exception('Object disposed exception');
    }

    var realizedService = _realizedServices.putIfAbsent(
      T,
      () => _createServiceAccessor!(T),
    );

    _onResolve(T, serviceProviderEngineScope);
    var result = realizedService!.call(serviceProviderEngineScope);
    assert(result != null || _callSiteFactory.isService(serviceType: T));

    if (result is List<dynamic>) {
      return result;
    }

    return result as T;
  }

  void _onCreate(ServiceCallSite callSite) {
    _callSiteValidator?.validateCallSite(callSite);
  }

  void _onResolve(Type serviceType, ServiceScope scope) {
    _callSiteValidator?.validateResolution(serviceType, scope, _root);
  }

  @override
  void dispose() {
    _disposed = true;
  }

  @override
  Future<void> disposeAsync() => _root.disposeAsync();
}

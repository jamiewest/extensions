part of 'service_lookup/service_lookup.dart';

typedef CreateServiceAccessor = CreateServiceAccessorInner? Function(
  ServiceIdentifier serviceIdentifier,
);

typedef CreateServiceAccessorInner = Object? Function(
  ServiceProviderEngineScope scope,
);

/// The default [ServiceProvider]
class DefaultServiceProvider
    implements
        ServiceProvider,
        KeyedServiceProvider,
        Disposable,
        AsyncDisposable {
  CallSiteValidator? _callSiteValidator;
  // late final ServiceAccessor Function(ServiceIdentifier serviceIdentifier)
  //     _createServiceAccessors;
  final ServiceProviderEngine _engine;
  bool _disposed = false;
  final Map<ServiceIdentifier, ServiceAccessor> _serviceAccessors;

  late final CallSiteFactory _callSiteFactory;

  late final ServiceProviderEngineScope _root;

  DefaultServiceProvider(
    Iterable<ServiceDescriptor> serviceDescriptors,
    ServiceProviderOptions options,
  )   : _engine = RuntimeServiceProviderEngine(),
        _serviceAccessors = <ServiceIdentifier, ServiceAccessor>{} {
    // note that Root needs to be set before calling GetEngine(), because
    // the engine may need to access Root
    _root = ServiceProviderEngineScope(this, isRootScope: true);
    var callSiteFactory = CallSiteFactory(serviceDescriptors);

    callSiteFactory
      ..add(ServiceIdentifier.fromServiceType(ServiceProvider),
          ServiceProviderCallSite())
      ..add(ServiceIdentifier.fromServiceType(ServiceScopeFactory),
          ConstantCallSite(ServiceScopeFactory, _root))
      ..add(ServiceIdentifier.fromServiceType(ServiceProviderIsService),
          ConstantCallSite(ServiceProviderIsService, callSiteFactory))
      ..add(ServiceIdentifier.fromServiceType(ServiceProviderIsKeyedService),
          ConstantCallSite(ServiceProviderIsKeyedService, callSiteFactory));

    _callSiteFactory = callSiteFactory;

    if (options.validateScopes) {
      _callSiteValidator = CallSiteValidator();
    }

    if (options.validateOnBuild) {
      List<Exception>? exceptions;
      for (var serviceDescriptor in serviceDescriptors) {
        try {
          _validateService(serviceDescriptor);
        } on Exception catch (e) {
          exceptions ??= <Exception>[];
          exceptions.add(e);
        }
      }

      if (exceptions != null) {
        throw AggregateException(
          message: 'Some services are not able to be constructed.',
          innerExceptions: exceptions,
        );
      }
    }
  }

  @override
  Object? getServiceFromType(Type type) =>
      _getService(ServiceIdentifier.fromServiceType(type), _root);

  @override
  Object? getKeyedServiceFromType(Type serviceType, Object? serviceKey,
          [ServiceProviderEngineScope? scope]) =>
      _getService(
          ServiceIdentifier(
            serviceKey: serviceKey,
            serviceType: serviceType,
          ),
          scope ?? _root);

  @override
  Object getRequiredKeyedServiceFromType(Type serviceType, Object? serviceKey,
      [ServiceProviderEngineScope? scope]) {
    var service =
        getKeyedServiceFromType(serviceType, serviceKey, scope ?? _root);
    if (service == null) {
      throw InvalidOperationException(
        message: 'No service for type \'$serviceType\' has been registered.',
      );
    }
    return service;
  }

  bool _isDisposed() => _disposed;

  @override
  void dispose() {
    _disposeCore();
    _root.dispose();
  }

  @override
  Future<void> disposeAsync() {
    _disposeCore();
    return _root.disposeAsync();
  }

  void _disposeCore() {
    _disposed = true;
  }

  void _onCreate(ServiceCallSite callSite) {
    _callSiteValidator?.validateCallSite(callSite);
  }

  void _onResolve(ServiceCallSite? callSite, ServiceScope scope) {
    if (callSite != null) {
      _callSiteValidator?.validateResolution(callSite, scope, _root);
    }
  }

  Object? _getService(
    ServiceIdentifier serviceIdentifier,
    ServiceProviderEngineScope serviceProviderEngineScope,
  ) {
    if (_disposed) {
      ThrowHelper.throwObjectDisposedException();
    }

    if (!_serviceAccessors.containsKey(serviceIdentifier)) {
      _serviceAccessors[serviceIdentifier] =
          _createServiceAccessor(serviceIdentifier);
    }

    var serviceAccessor = _serviceAccessors[serviceIdentifier];

    // var serviceAccessor = _serviceAccessors.putIfAbsent(
    //   serviceIdentifier,
    //   () => _createServiceAccessor(serviceIdentifier),
    // );
    _onResolve(serviceAccessor!.callSite, serviceProviderEngineScope);
    var result =
        serviceAccessor.realizedService?.call(serviceProviderEngineScope);
    assert(result != null || !_callSiteFactory._isService(serviceIdentifier));
    return result;
  }

  void _validateService(ServiceDescriptor descriptor) {
    try {
      var callSite = _callSiteFactory.getCallSite(descriptor, CallSiteChain());
      if (callSite != null) {
        _onCreate(callSite);
      }
    } on Exception catch (e) {
      throw InvalidOperationException(
        message: 'Error while validating the service descriptor'
            ' \'$descriptor\': $e',
      );
    }
  }

  ServiceAccessor _createServiceAccessor(ServiceIdentifier serviceIdentifier) {
    var callSite = _callSiteFactory.getCallSiteFromServiceIdentifer(
      serviceIdentifier,
      CallSiteChain(),
    );
    if (callSite != null) {
      _onCreate(callSite);

      // Optimize singleton case
      if (callSite.cache.location == CallSiteResultCacheLocation.root) {
        var value = CallSiteRuntimeResolver.instance.resolve(callSite, _root);
        return ServiceAccessor()
          ..callSite = callSite
          ..realizedService = (scope) => value;
      }

      var realizedService = _engine.realizeService(callSite);
      return ServiceAccessor()
        ..callSite = callSite
        ..realizedService = realizedService;
    }
    return ServiceAccessor()
      ..callSite = callSite
      ..realizedService = (_) => null;
  }

  ServiceScope createScope() {
    if (_disposed) {
      ThrowHelper.throwObjectDisposedException();
    }
    return ServiceProviderEngineScope(this, isRootScope: false);
  }
}

class ServiceAccessor {
  ServiceCallSite? callSite;
  Object? Function(ServiceProviderEngineScope scope)? realizedService;
}

import './service_lookup/call_site_visitor.dart';
import './service_lookup/constant_call_site.dart';
import './service_lookup/factory_call_site.dart';
import './service_lookup/iterable_call_site.dart';
import './service_lookup/service_call_site.dart';
import './service_lookup/service_provider_call_site.dart';
import './service_lookup/service_scope_factory_call_site.dart';
import '../shared/async_disposable.dart';
import '../shared/disposable.dart';
import '../shared/type_helpers.dart';
import 'service_collection.dart';
import 'service_descriptor.dart';
import 'service_lookup/call_site_chain.dart';
import 'service_lookup/call_site_factory.dart';
import 'service_lookup/call_site_result_cache_location.dart';
import 'service_lookup/call_site_validator.dart';
import 'service_lookup/runtime_service_provider_engine.dart';
import 'service_lookup/service_cache_kind.dart';
import 'service_lookup/service_provider_engine.dart';
import 'service_provider_is_service.dart';
import 'service_provider_options.dart';
import 'service_scope.dart';
import 'service_scope_factory.dart';

/// @nodoc
typedef CreateServiceAccessor = CreateServiceAccessorInner? Function(
  Type type,
);

/// @nodoc
typedef CreateServiceAccessorInner = Object? Function(
  ServiceProviderEngineScope scope,
);

/// Defines a mechanism for retrieving a service object; that is,
/// an object that provides custom support to other objects.
class ServiceProvider implements Disposable, AsyncDisposable {
  CallSiteValidator? _callSiteValidator;
  CreateServiceAccessor? _createServiceAccessor;
  // Internal for testing
  final ServiceProviderEngine _engine;
  bool _disposed;
  final Map<Type, CreateServiceAccessorInner?> _realizedServices;
  final CallSiteFactory __callSiteFactory;
  ServiceProviderEngineScope? __root;

  // Internal constructor.
  ServiceProvider._(
    Iterable<ServiceDescriptor> serviceDescriptors,
    ServiceProviderOptions options,
  )   : _engine = RuntimeServiceProviderEngine(),
        _realizedServices = <Type, CreateServiceAccessorInner?>{},
        _disposed = false,
        __callSiteFactory = CallSiteFactory(serviceDescriptors) {
    _createServiceAccessor = (serviceType) {
      var callSite = __callSiteFactory.getCallSiteFromType(
        serviceType,
        CallSiteChain(),
      );
      if (callSite != null) {
        _onCreate(callSite);

        // Optimize singleton case
        if (callSite.cache.location == CallSiteResultCacheLocation.root) {
          var value =
              CallSiteRuntimeResolver.instance.resolve(callSite, __root!);
          return (scope) => value;
        }

        return _engine.realizeService(callSite);
      }
      return (_) => null;
    };
    __root = ServiceProviderEngineScope(this);

    __callSiteFactory
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

  // Internal
  CallSiteFactory get _callSiteFactory => __callSiteFactory;

  // Internal
  ServiceProviderEngineScope get _root => __root!;

  void _validateService(ServiceDescriptor descriptor) {
    try {
      var callSite = _callSiteFactory.getCallSite(descriptor, CallSiteChain());
      if (callSite != null) {
        _onCreate(callSite);
      }
    } catch (e) {
      throw Exception('Error while validating the service descriptor');
    }
  }

  // Internal
  ServiceScope _createScope() {
    if (_disposed) {
      throw Exception('Disposed Exception');
    }
    return ServiceProviderEngineScope(this);
  }

  /// Gets the service object of the specified type.
  T getService<T>() => _getServiceInternal<T>(_root);

  /// Get an enumeration of services of type [T] from the [ServiceProvider].
  Iterable<T> getServices<T>() {
    if (_disposed) {
      throw Exception('Object disposed exception');
    }

    var serviceProviderEngineScope = _root;

    //var a = typeOf<Iterable<T>>();

    // Changed a to T.
    var realizedService =
        _realizedServices.putIfAbsent(T, () => _createServiceAccessor!(T));
    _onResolve(T, serviceProviderEngineScope);
    var result = realizedService!.call(serviceProviderEngineScope);
    //assert(result != null || callSiteFactory.isService<Iterable<T>>());

    if (result is List) {
      return result.map((e) => e as T);
    } else {
      return [result as T];
    }
  }

  T _getServiceInternal<T>([ServiceScope? scope]) => _getService<T>(
        scope == null ? _root : scope as ServiceProviderEngineScope,
      );

  T _getService<T>(
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

    if (result is List) {}

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

/// Extension methods for building a [ServiceProvider] from a
/// [ServiceCollection].
extension ServiceCollectionContainerBuilderExtensions on ServiceCollection {
  /// Creates a [ServiceProvider] containing services from the
  /// provided [ServiceCollection].
  ServiceProvider buildServiceProvider([ServiceProviderOptions? options]) =>
      ServiceProvider._(
        this,
        options ??= ServiceProviderOptions(),
      );
}

/// @nodoc
class CallSiteRuntimeResolver
    extends CallSiteVisitor<RuntimeResolverContext, Object> {
  static CallSiteRuntimeResolver get instance => CallSiteRuntimeResolver();

  Object? resolve(
    ServiceCallSite callSite,
    ServiceProviderEngineScope scope,
  ) =>
      visitCallSite(
        callSite,
        RuntimeResolverContext(scope: scope),
      );

  @override
  Object visitDisposeCache(
    ServiceCallSite callSite,
    RuntimeResolverContext argument,
  ) =>
      argument.scope!.captureDisposable(
        visitCallSiteMain(callSite, argument),
      );

  @override
  Object visitRootCache(
    ServiceCallSite callSite,
    RuntimeResolverContext argument,
  ) =>
      resolveService(
        callSite,
        argument,
        argument.scope!.rootProvider._root,
      );

  @override
  Object visitScopeCache(
    ServiceCallSite callSite,
    RuntimeResolverContext argument,
  ) =>
      argument.scope! == argument.scope!.rootProvider._root
          ? visitRootCache(callSite, argument)
          : _visitCache(
              callSite,
              argument,
              argument.scope!,
            );

  Object _visitCache(
    ServiceCallSite callSite,
    RuntimeResolverContext argument,
    ServiceProviderEngineScope serviceProviderEngine,
  ) =>
      resolveService(
        callSite,
        argument,
        serviceProviderEngine,
      );

  Object resolveService(
    ServiceCallSite callSite,
    RuntimeResolverContext context,
    ServiceProviderEngineScope serviceProviderEngine,
  ) {
    var resolvedServices = serviceProviderEngine.resolvedServices;

    Object? resolved;
    if (resolvedServices.containsKey(callSite.cache.key)) {
      return resolvedServices[callSite.cache.key]!;
    }

    resolved = visitCallSiteMain(
        callSite,
        RuntimeResolverContext(
          scope: serviceProviderEngine,
          acquiredLocks: context.acquiredLocks,
        ));
    serviceProviderEngine.captureDisposable(resolved);
    serviceProviderEngine.resolvedServices[callSite.cache.key] = resolved;
    return resolved;
  }

  @override
  Object visitConstant(
    ConstantCallSite constantCallSite,
    RuntimeResolverContext argument,
  ) =>
      constantCallSite.defaultValue!;

  @override
  Object visitServiceProvider(
    ServiceProviderCallSite serviceProviderCallSite,
    RuntimeResolverContext argument,
  ) =>
      argument.scope!;

  @override
  Object visitServiceScopeFactory(
    ServiceScopeFactoryCallSite serviceScopeFactoryCallSite,
    RuntimeResolverContext argument,
  ) =>
      serviceScopeFactoryCallSite.value;

  @override
  Object visitIterable(
    IterableCallSite iterableCallSite,
    RuntimeResolverContext argument,
  ) {
    var items = [];
    for (var i = 0; i < iterableCallSite.serviceCallSites.length; i++) {
      var value = visitCallSite(
          iterableCallSite.serviceCallSites.elementAt(i), argument);
      items.add(value);
    }
    return items;
  }

  @override
  Object visitFactory(
    FactoryCallSite factoryCallSite,
    RuntimeResolverContext argument,
  ) =>
      factoryCallSite.factory(argument.scope!) as Object;
}

/// @nodoc
class RuntimeResolverContext {
  RuntimeResolverContext({
    this.scope,
    this.acquiredLocks,
  });

  ServiceProviderEngineScope? scope;
  RuntimeResolverLock? acquiredLocks;
}

/// @nodoc
enum RuntimeResolverLock { scope, root }

/// @nodoc
class ServiceProviderEngineScope
    implements
        ServiceScope,
        ServiceProvider,
        AsyncDisposable,
        ServiceScopeFactory {
  // For testing only
  List<Object> get disposables => _disposables ?? <Object>[];
  @override
  bool _disposed;
  List<Object>? _disposables;

  final Map<ServiceCacheKey, Object> _resolvedServices;
  final ServiceProvider _rootProvider;

  ServiceProviderEngineScope(ServiceProvider serviceProvider)
      : _resolvedServices = <ServiceCacheKey, Object>{},
        _rootProvider = serviceProvider,
        _disposed = false;

  Map<ServiceCacheKey, Object> get resolvedServices => _resolvedServices;
  bool get isRootScope => this == _rootProvider._root;
  ServiceProvider get rootProvider => _rootProvider;

  @override
  ServiceProvider get serviceProvider => this;

  @override
  ServiceScope createScope() => rootProvider._createScope();

  @override
  T getService<T>() {
    if (_disposed) {
      throw Exception('Object disposed exception');
    }

    return rootProvider._getServiceInternal<T>(this);
  }

  @override
  Iterable<T> getServices<T>() {
    if (_disposed) {
      throw Exception('Object disposed exception');
    }
    return rootProvider.getServices<T>();
  }

  Object captureDisposable(Object service) {
    if (this == service || service is! Disposable) {
      return service;
    }

    if (_disposed) {
      if (service is Disposable) {
        service.dispose();
      }
    }

    _disposables ??= <Object>[];
    _disposables?.add(service);

    return service;
  }

  @override
  void dispose() {
    var toDispose = _beginDispose();
    if (toDispose != null) {
      for (var i = toDispose.length - 1; i >= 0; i--) {
        if (toDispose[i] is Disposable) {
          (toDispose[i] as Disposable).dispose();
        } else {
          throw Exception('R.AsyncDisposableServiceDispose');
        }
      }
    }
  }

  List<Object>? _beginDispose() {
    List<Object> toDispose;
    if (_disposed) {
      return null;
    }

    _disposed = true;
    toDispose = _disposables!;
    _disposables = null;

    return toDispose;
  }

  @override
  Future<void> disposeAsync() async {
    var toDispose = _beginDispose();
    if (toDispose != null) {
      try {
        for (var i = toDispose.length - 1; i >= 0; i--) {
          if (toDispose[i] is AsyncDisposable) {
            await (toDispose[i] as AsyncDisposable).disposeAsync();
          } else {
            (toDispose[i] as Disposable).dispose();
          }
        }
      } on Exception catch (e) {
        // TODO: Catch this error.
        //print(e.toString());
      }
    }
  }

  @override
  ServiceProviderEngineScope? get __root => _rootProvider.__root;

  @override
  set __root(ServiceProviderEngineScope? value) => _rootProvider.__root = value;

  @override
  CallSiteValidator? _callSiteValidator;

  @override
  CreateServiceAccessor? get _createServiceAccessor =>
      _rootProvider._createServiceAccessor;

  @override
  set _createServiceAccessor(CreateServiceAccessor? value) =>
      _rootProvider._createServiceAccessor = value;

  @override
  CallSiteFactory get __callSiteFactory => _rootProvider.__callSiteFactory;

  @override
  CallSiteFactory get _callSiteFactory => _rootProvider._callSiteFactory;

  @override
  ServiceScope _createScope() => _rootProvider._createScope();

  @override
  ServiceProviderEngine get _engine => _rootProvider._engine;

  @override
  T _getService<T>(
    covariant ServiceProviderEngineScope serviceProviderEngineScope,
  ) =>
      _rootProvider._getService<T>(serviceProviderEngineScope);

  @override
  void _onCreate(ServiceCallSite callSite) => _rootProvider._onCreate(callSite);

  @override
  void _onResolve(Type serviceType, ServiceScope scope) =>
      _rootProvider._onResolve(serviceType, scope);

  @override
  Map<Type, CreateServiceAccessorInner?> get _realizedServices =>
      _rootProvider._realizedServices;

  @override
  ServiceProviderEngineScope get _root => _rootProvider._root;

  @override
  void _validateService(ServiceDescriptor descriptor) =>
      _rootProvider._validateService(descriptor);

  @override
  T _getServiceInternal<T>([ServiceScope? scope]) =>
      _rootProvider._getServiceInternal<T>(scope);
}

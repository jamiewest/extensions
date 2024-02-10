// import 'package:extensions/src/dependency_injection/keyed_service_provider.dart';

// import '../common/async_disposable.dart';
// import '../common/disposable.dart';
// import 'service_descriptor.dart';
// import 'service_lookup/call_site_chain.dart';
// import 'service_lookup/call_site_factory.dart';
// import 'service_lookup/call_site_result_cache_location.dart';
// import 'service_lookup/call_site_runtime_resolver.dart';
// import 'service_lookup/call_site_validator.dart';
// import 'service_lookup/constant_call_site.dart';
// import 'service_lookup/runtime_service_provider_engine.dart';
// import 'service_lookup/service_call_site.dart';
// import 'service_lookup/service_lookup.dart';
// import 'service_lookup/service_provider_call_site.dart';
// import 'service_lookup/service_provider_engine.dart';
// import 'service_lookup/service_provider_engine_scope.dart';
// import 'service_provider.dart';
// import 'service_provider_is_service.dart';
// import 'service_provider_options.dart';
// import 'service_scope.dart';
// import 'service_scope_factory.dart';

// typedef CreateServiceAccessor = CreateServiceAccessorInner? Function(
//   Type type,
// );

// typedef CreateServiceAccessorInner = Object? Function(
//   ServiceProviderEngineScope scope,
// );

// class ServiceProviderImpl
//     implements
//         ServiceProvider,
//         KeyedServiceProvider,
//         Disposable,
//         AsyncDisposable {
//   CallSiteValidator? _callSiteValidator;
//   CreateServiceAccessor? _createServiceAccessor;
//   // Internal for testing
//   final ServiceProviderEngine _engine;
//   bool _disposed;
//   final Map<Type, CreateServiceAccessorInner?> _realizedServices;
//   final CallSiteFactory _callSiteFactory;
//   late final ServiceProviderEngineScope _root;

//   // Internal constructor.
//   ServiceProviderImpl(
//     Iterable<ServiceDescriptor> serviceDescriptors,
//     ServiceProviderOptions options,
//   )   : _engine = RuntimeServiceProviderEngine(),
//         _realizedServices = <Type, CreateServiceAccessorInner?>{},
//         _disposed = false,
//         _callSiteFactory = CallSiteFactory(serviceDescriptors) {
//     _createServiceAccessor = (serviceType) {
//       var callSite = _callSiteFactory.getCallSiteFromType(
//         serviceType,
//         CallSiteChain(),
//       );
//       if (callSite != null) {
//         _onCreate(callSite);

//         // Optimize singleton case
//         if (callSite.cache.location == CallSiteResultCacheLocation.root) {
//           var value = CallSiteRuntimeResolver.instance.resolve(callSite, _root);
//           return (scope) => value;
//         }

//         return _engine.realizeService(callSite);
//       }
//       return (_) => null;
//     };
//     _root = ServiceProviderEngineScope(this, isRootScope: true);

//     _callSiteFactory
//       ..add(ServiceProvider, ServiceProviderCallSite())
//       ..add(ServiceScopeFactory, ConstantCallSite(ServiceScopeFactory, root))
//       ..add(ServiceProviderIsService,
//           ConstantCallSite(ServiceProviderIsService, _callSiteFactory));

//     if (options.validateScopes) {
//       _callSiteValidator = CallSiteValidator();
//     }

//     if (options.validateOnBuild) {
//       var exceptions = <Exception>[];
//       for (var serviceDescriptor in serviceDescriptors) {
//         try {
//           _validateService(serviceDescriptor);
//         } catch (e) {
//           exceptions.add(e as Exception);
//         }
//       }

//       if (exceptions.isNotEmpty) {
//         throw Exception('Some services are not able to be constructed');
//       }
//     }
//   }

//   CallSiteFactory get callSiteFactory => _callSiteFactory;

//   ServiceProviderEngineScope get root => _root;

//   void _validateService(ServiceDescriptor descriptor) {
//     try {
//       var callSite = _callSiteFactory.getCallSite(descriptor, CallSiteChain());
//       if (callSite != null) {
//         _onCreate(callSite);
//       }
//     } on Exception catch (e) {
//       throw Exception(
//         'Error while validating the service descriptor'
//         ' \'${descriptor.toString()}\': ${e.toString()}',
//       );
//     }
//   }

//   ServiceScope createScope() {
//     if (_disposed) {
//       throw Exception('Disposed Exception');
//     }
//     return ServiceProviderEngineScope(this, isRootScope: false);
//   }

//   /// Gets the service object of the specified type.
//   @override
//   T? getService<T>([ServiceScope? scope]) => _getService<T>(
//         scope == null ? _root : scope as ServiceProviderEngineScope,
//       );

//   T? _getService<T>(
//       covariant ServiceProviderEngineScope serviceProviderEngineScope) {
//     if (_disposed) {
//       throw Exception('Object disposed exception');
//     }

//     var realizedService = _realizedServices.putIfAbsent(
//       T,
//       () => _createServiceAccessor!(T),
//     );

//     _onResolve(T, serviceProviderEngineScope);
//     var result = realizedService!.call(serviceProviderEngineScope);
//     //assert(result is Never || _callSiteFactory.isService(serviceType: T));
//     if (result == null) {
//       return null;
//     }
//     return result as T;
//   }

//   @override
//   Iterable<T> getServices<T>([ServiceScope? scope]) => _getServices<T>(
//         scope == null ? _root : scope as ServiceProviderEngineScope,
//       );

//   Iterable<T> _getServices<T>(
//       covariant ServiceProviderEngineScope serviceProviderEngineScope) {
//     if (_disposed) {
//       throw Exception('Object disposed exception');
//     }

//     var realizedService = _realizedServices.putIfAbsent(
//       Iterable<T>,
//       () => _createServiceAccessor!(Iterable<T>),
//     );

//     _onResolve(Iterable<T>, serviceProviderEngineScope);
//     var result = realizedService!.call(serviceProviderEngineScope);
//     assert(
//         result != null || _callSiteFactory.isService(serviceType: Iterable<T>));

//     if (result is List<dynamic>) {
//       final x = result.cast<T>();
//       return x;
//     }

//     throw Exception('Error bitches');
//   }

//   void _onCreate(ServiceCallSite callSite) {
//     _callSiteValidator?.validateCallSite(callSite);
//   }

//   void _onResolve(Type serviceType, ServiceScope scope) {
//     _callSiteValidator?.validateResolution(serviceType, scope, _root);
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//   }

//   @override
//   Future<void> disposeAsync() => _root.disposeAsync();

//   @override
//   T? getKeyedService<T>(Object? serviceKey,
//       [ServiceProviderEngineScope? serviceProviderEngineScope]) {
//     throw UnimplementedError();
//   }

//   @override
//   T getRequiredKeyedService<T>(Object? serviceKey,
//       [ServiceProviderEngineScope? serviceProviderEngineScope]) {
//     throw UnimplementedError();
//   }

//   @override
//   Iterable<T> getKeyedServices<T>(Object? serviceKey) {
//     throw UnimplementedError();
//   }
// }

// extension IterableExtension<T> on Iterable<T> {
//   Iterable<T> converty(List<dynamic> x) => x.map((y) => y as T).toList();
// }

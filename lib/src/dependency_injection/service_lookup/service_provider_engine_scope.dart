// import '../../shared/async_disposable.dart';

// import '../../shared/disposable.dart';
// import '../service_provider.dart';
// import '../service_scope.dart';
// import '../service_scope_factory.dart';
// import 'service_cache_kind.dart';

// class ServiceProviderEngineScope
//     implements ServiceScope, ServiceProvider, ServiceScopeFactory {
//   // For testing only
//   List<Object> get disposables => _disposables ?? <Object>[];
//   bool _disposed;
//   List<Object>? _disposables;

//   final Map<ServiceCacheKey, Object> _resolvedServices;
//   final ServiceProvider _rootProvider;

//   ServiceProviderEngineScope(ServiceProvider serviceProvider)
//       : _resolvedServices = <ServiceCacheKey, Object>{},
//         _rootProvider = serviceProvider,
//         _disposed = false;

//   Map<ServiceCacheKey, Object> get resolvedServices => _resolvedServices;
//   bool get isRootScope => this == _rootProvider.root;
//   ServiceProvider get rootProvider => _rootProvider;

//   @override
//   ServiceProvider get serviceProvider => this;

//   @override
//   ServiceScope createScope() => rootProvider.createScope();

//   @override
//   T getService<T>() {
//     if (_disposed) {
//       throw Exception('Object disposed exception');
//     }

//     return rootProvider.getServiceInternal<T>(this);
//   }

//   @override
//   Iterable<T> getServices<T>() {
//     if (_disposed) {
//       throw Exception('Object disposed exception');
//     }
//     return rootProvider.getServices<T>();
//   }

//   Object captureDisposable(Object service) {
//     if (this == service || service is! Disposable) {
//       return service;
//     }

//     if (_disposed) {
//       if (service is Disposable) {
//         service.dispose();
//       }
//     }

//     _disposables ??= <Object>[];
//     _disposables?.add(service);

//     return service;
//   }

//   @override
//   void dispose() {
//     var toDispose = _beginDispose();
//     if (toDispose != null) {
//       for (var i = toDispose.length - 1; i >= 0; i--) {
//         if (toDispose[i] is Disposable) {
//           (toDispose[i] as Disposable).dispose();
//         } else {
//           throw Exception('R.AsyncDisposableServiceDispose');
//         }
//       }
//     }
//   }

//   List<Object>? _beginDispose() {
//     List<Object> toDispose;
//     if (_disposed) {
//       return null;
//     }

//     _disposed = true;
//     toDispose = _disposables!;
//     _disposables = null;

//     return toDispose;
//   }

//   @override
//   Future<void> disposeAsync() async {
//     var toDispose = _beginDispose();
//     if (toDispose != null) {
//       try {
//         for (var i = toDispose.length - 1; i >= 0; i--) {
//           if (toDispose[i] is AsyncDisposable) {
//             await (toDispose[i] as AsyncDisposable).disposeAsync();
//           } else {
//             (toDispose[i] as Disposable).dispose();
//           }
//         }
//       } on Exception catch (e) {}
//     }
//   }
// }

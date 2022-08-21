import '../../primitives/async_disposable.dart';
import '../../primitives/disposable.dart';
import '../service_provider.dart';
import '../service_provider_impl.dart';
import '../service_scope.dart';
import '../service_scope_factory.dart';
import 'service_cache_key.dart';

class ServiceProviderEngineScope
    implements
        ServiceScope,
        ServiceProvider,
        AsyncDisposable,
        ServiceScopeFactory {
  // For testing only
  List<Object> get disposables => _disposables ?? <Object>[];
  bool _disposed = false;
  List<Object>? _disposables;
  final bool _isRootScope;

  final Map<ServiceCacheKey, Object?> _resolvedServices;
  final ServiceProviderImpl _rootProvider;

  ServiceProviderEngineScope(
    ServiceProviderImpl provider, {
    required bool isRootScope,
  })  : _resolvedServices = <ServiceCacheKey, Object?>{},
        _rootProvider = provider,
        _isRootScope = isRootScope;

  Map<ServiceCacheKey, Object?> get resolvedServices => _resolvedServices;

  bool get isRootScope => _isRootScope;

  ServiceProviderImpl get rootProvider => _rootProvider;

  @override
  T? getService<T>() {
    if (_disposed) {
      throw Exception('Cannot access a disposed object.');
    }

    return rootProvider.getService<T>(this);
  }

  @override
  Iterable<T> getServices<T>() {
    if (_disposed) {
      throw Exception('Cannot access a disposed object.');
    }

    return rootProvider.getServices<T>(this);
  }

  @override
  ServiceProvider get serviceProvider => this;

  @override
  ServiceScope createScope() => rootProvider.createScope();

  Object captureDisposable(Object service) {
    if (this == service || service is! Disposable) {
      return service;
    }

    if (_disposed) {
      service.dispose();
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
          throw Exception(
              '\'${toDispose[i]}\' type only implements IAsyncDisposable. Use DisposeAsync to dispose the container.');
        }
      }
    }
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
        return Future.error(e);
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
}

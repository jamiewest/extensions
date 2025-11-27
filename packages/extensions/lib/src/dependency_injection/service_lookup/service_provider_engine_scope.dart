part of 'service_lookup.dart';

class ServiceProviderEngineScope
    implements
        ServiceScope,
        ServiceProvider,
        KeyedServiceProvider,
        AsyncDisposable,
        ServiceScopeFactory {
  // For testing only
  List<Object> get disposables => _disposables ?? <Object>[];
  bool _disposed = false;
  List<Object>? _disposables;
  final bool _isRootScope;

  final Map<ServiceCacheKey, Object?> _resolvedServices;
  final DefaultServiceProvider _rootProvider;
  final CallSiteChain _resolutionChain = CallSiteChain();

  ServiceProviderEngineScope(
    DefaultServiceProvider provider, {
    bool isRootScope = false,
  })  : _resolvedServices = <ServiceCacheKey, Object?>{},
        _rootProvider = provider,
        _isRootScope = isRootScope;

  Map<ServiceCacheKey, Object?> get resolvedServices => _resolvedServices;

  bool get isRootScope => _isRootScope;

  DefaultServiceProvider get rootProvider => _rootProvider;

  @override
  Object? getServiceFromType(Type type) {
    if (_disposed) {
      ThrowHelper.throwObjectDisposedException();
    }

    return _rootProvider._getService(
        ServiceIdentifier.fromServiceType(type), this);
  }

  @override
  Object? getKeyedServiceFromType(Type serviceType, Object? serviceKey) {
    if (_disposed) {
      ThrowHelper.throwObjectDisposedException();
    }

    return rootProvider.getKeyedServiceFromType(serviceType, serviceKey, this);
  }

  @override
  Object getRequiredKeyedServiceFromType(Type serviceType, Object? serviceKey) {
    if (_disposed) {
      ThrowHelper.throwObjectDisposedException();
    }

    return rootProvider.getRequiredKeyedServiceFromType(
      serviceType,
      serviceKey,
      this,
    );
  }

  @override
  ServiceProvider get serviceProvider => this;

  @override
  ServiceScope createScope() => rootProvider.createScope();

  Object? captureDisposable(Object? service) {
    if (this == service ||
        service is! Disposable ||
        service is AsyncDisposable) {
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
            '\'${toDispose[i]}\' type only implements AsyncDisposable.'
            ' Use DisposeAsync to dispose the container.',
          );
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
    if (_disposed) {
      return null;
    }

    _disposed = true;

    if (isRootScope && !rootProvider._isDisposed()) {
      rootProvider.dispose();
    }
    return _disposables;
  }
}

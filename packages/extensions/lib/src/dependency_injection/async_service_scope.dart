import '../system/async_disposable.dart';
import 'service_provider.dart';
import 'service_scope.dart';

/// A [ServiceScope] implementation that implements [AsyncDisposable].
///
/// Adapted from [Microsoft.Extensions.DependencyInjection.AsyncServiceScope](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.asyncservicescope)
class AsyncServiceScope implements ServiceScope, AsyncDisposable {
  final ServiceScope _serviceScope;

  /// Initializes a new instance of the [AsyncServiceScope] class. Wraps
  /// an instance of [ServiceScope].
  const AsyncServiceScope(ServiceScope serviceScope)
      : _serviceScope = serviceScope;

  @override
  ServiceProvider get serviceProvider => _serviceScope.serviceProvider;

  @override
  void dispose() => _serviceScope.dispose();

  @override
  Future<void> disposeAsync() {
    if (_serviceScope is AsyncDisposable) {
      return (_serviceScope as AsyncDisposable).disposeAsync();
    }
    _serviceScope.dispose();

    return Future.value();
  }
}

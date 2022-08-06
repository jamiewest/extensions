import 'package:extensions/hosting.dart';

class FakeServiceCollection implements ServiceProvider {
  ServiceProvider? _inner;
  ServiceCollection? _services;

  bool fancyMethodCalled = false;

  ServiceCollection? get services => _services;

  String? state;

  @override
  T getService<T>() => _inner!.getRequiredService<T>() as T;

  // @override
  // Iterable<T> getServices<T>() => _inner!.getServices<T>();

  void populate(ServiceCollection services) {
    _services = services;
    _services!.addSingleton<FakeServiceCollection, FakeServiceCollection>(
        (_) => this);
  }

  void build() {
    _inner = _services!.buildServiceProvider();
  }

  void myFancyContainerMethod() {
    fancyMethodCalled = true;
  }

  // @override
  // void dispose() {}

  // @override
  // Future<void> disposeAsync() {
  //   throw UnimplementedError();
  // }
}

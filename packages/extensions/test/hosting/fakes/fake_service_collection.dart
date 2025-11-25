import 'package:extensions/dependency_injection.dart';

class FakeServiceCollection implements ServiceProvider {
  ServiceProvider? _inner;
  ServiceCollection? _services;

  bool fancyMethodCalled = false;

  ServiceCollection? get services => _services;

  String? state;

  T getService<T>() => _inner!.getRequiredService<T>();

  Iterable<T> getServices<T>() => _inner!.getServices<T>();

  void populate(ServiceCollection services) {
    _services = services;
    _services!.addSingleton<FakeServiceCollection>((_) => this);
  }

  void build() {
    _inner = _services!.buildServiceProvider();
  }

  void myFancyContainerMethod() {
    fancyMethodCalled = true;
  }

  @override
  Object? getServiceFromType(Type type) {
    // TODO(jamiewest): implement getServiceFromType
    throw UnimplementedError();
  }
}

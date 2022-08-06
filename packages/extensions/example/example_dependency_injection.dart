import 'package:extensions/dependency_injection.dart';

void main() {
  ((ServiceCollection()
        ..addSingleton<MyService, MyService>(
          (_) => MyService(),
        )
        ..buildServiceProvider().getRequiredService<MyService>()) as MyService)
      .doSomething();
}

class MyService {
  void doSomething() {
    print('MyService.doSomething');
  }
}

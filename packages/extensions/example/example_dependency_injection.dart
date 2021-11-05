import 'package:extensions/dependency_injection.dart';

void main() {
  ServiceCollection()
    ..addSingleton<MyService>(
      implementationInstance: MyService(),
    )
    ..buildServiceProvider().getRequiredService<MyService>().doSomething();
}

class MyService {
  void doSomething() {
    print('MyService.doSomething');
  }
}

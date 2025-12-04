import 'package:extensions/dependency_injection.dart';

abstract class IService {
  String getName();
}

class ServiceA implements IService {
  @override
  String getName() => 'ServiceA';
}

class ServiceB implements IService {
  @override
  String getName() => 'ServiceB';
}

class ServiceC implements IService {
  @override
  String getName() => 'ServiceC';
}

void main() {
  print('Testing multiple addSingleton calls...\n');

  // Create a service collection and register multiple services of the same type
  final services = ServiceCollection()
    ..addSingleton<IService>((_) => ServiceA())
    ..addSingleton<IService>((_) => ServiceB())
    ..addSingleton<IService>((_) => ServiceC());

  // Build the service provider
  final provider = services.buildServiceProvider();

  // Test 1: Get single service (should return the last registered)
  final singleService = provider.getService<IService>();
  print('Single service via getService<T>(): ${singleService?.getName()}');

  // Test 2: Get all services
  final allServices = provider.getServices<IService>();
  print('\nAll services via getServices<T>():');
  for (var service in allServices) {
    print('  - ${service.getName()}');
  }

  print('\nTotal services registered: ${allServices.length}');

  // Verify all three services are returned
  final names = allServices.map((s) => s.getName()).toList();
  assert(names.contains('ServiceA'), 'ServiceA not found');
  assert(names.contains('ServiceB'), 'ServiceB not found');
  assert(names.contains('ServiceC'), 'ServiceC not found');
  assert(allServices.length == 3, 'Expected 3 services, got ${allServices.length}');

  print('\n✓ All assertions passed!');
  print('✓ Multiple addSingleton calls ARE supported and can be retrieved via getServices<T>()');
}

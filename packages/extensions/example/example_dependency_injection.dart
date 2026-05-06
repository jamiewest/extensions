import 'package:extensions/dependency_injection.dart';

/// Demonstrates registering multiple services and resolving one from DI.
///
/// Run this file to see which `int` registration is returned by `getService`.
void main() {
  print('=== Dependency Injection Example ===');

  final serviceCollection = ServiceCollection()
    ..addSingleton<String>((services) => '1')
    ..addSingleton<String>((services) => '2')
    ..addSingleton<int>((services) => 3)
    ..addSingleton<int>((services) => 4)
    ..addSingleton<int>((services) => 5);
  final serviceProvider = serviceCollection.buildServiceProvider();

  print('--- Resolve int Service ---');
  final resolvedValue = serviceProvider.getService<int>();

  print('Resolved value: $resolvedValue');
}

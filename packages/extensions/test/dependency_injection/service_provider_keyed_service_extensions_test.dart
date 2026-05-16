import 'package:extensions/dependency_injection.dart';
import 'package:test/test.dart';

import 'fakes/fake_service.dart';

void main() {
  group('getKeyedServices', () {
    test('returns all services registered under the same key', () {
      final implA = FakeServiceImplementation();
      final implB = FakeServiceImplementation();
      final services = ServiceCollection()
        ..addKeyedSingletonInstance<FakeService>('my-key', implA)
        ..addKeyedSingletonInstance<FakeService>('my-key', implB);

      final sp = services.buildServiceProvider();
      final result = sp.getKeyedServices<FakeService>('my-key').toList();

      expect(result.length, 2);
      expect(result, containsAll([implA, implB]));
    });

    test('returns empty when no services registered under key', () {
      final services = ServiceCollection()
        ..addKeyedSingletonInstance<FakeService>(
            'other-key', FakeServiceImplementation());

      final sp = services.buildServiceProvider();
      final result =
          sp.getKeyedServices<FakeService>('unknown-key').toList();

      expect(result, isEmpty);
    });

    test('does not return services registered under a different key', () {
      final implA = FakeServiceImplementation();
      final implB = FakeServiceImplementation();
      final services = ServiceCollection()
        ..addKeyedSingletonInstance<FakeService>('key-a', implA)
        ..addKeyedSingletonInstance<FakeService>('key-b', implB);

      final sp = services.buildServiceProvider();

      expect(
        sp.getKeyedServices<FakeService>('key-a').toList(),
        equals([implA]),
      );
      expect(
        sp.getKeyedServices<FakeService>('key-b').toList(),
        equals([implB]),
      );
    });

    test('returns services in registration order', () {
      final impls = [
        FakeServiceImplementation(),
        FakeServiceImplementation(),
        FakeServiceImplementation(),
      ];
      final services = ServiceCollection();
      for (final impl in impls) {
        services.addKeyedSingletonInstance<FakeService>('key', impl);
      }

      final sp = services.buildServiceProvider();
      final result = sp.getKeyedServices<FakeService>('key').toList();

      expect(result, orderedEquals(impls));
    });

    test('getKeyedServicesFromType throws UnsupportedError', () {
      final services = ServiceCollection()
        ..addKeyedSingletonInstance<FakeService>(
            'key', FakeServiceImplementation());
      final sp = services.buildServiceProvider();

      expect(
        () => sp.getKeyedServicesFromType(FakeService, 'key'),
        throwsUnsupportedError,
      );
    });
  });
}

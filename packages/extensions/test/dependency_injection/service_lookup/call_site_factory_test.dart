import 'dart:math';

import 'package:extensions/hosting.dart';
import 'package:extensions/src/dependency_injection/service_collection.dart';
import 'package:test/test.dart';

import '../fakes/fake_service.dart';

void main() {
  group('CallSiteFactoryTest', () {
    test('GetService_FactoryCallSite_Transient_DoesNotFail', () {
      var collection = ServiceCollection()
        ..add(
          ServiceDescriptor.describe<FakeServiceImplementation>(
            implementationFactory: (sp) => FakeServiceImplementation(),
            lifetime: ServiceLifetime.transient,
          ),
        )
        ..add(
          ServiceDescriptor.describe<FakeService>(
            implementationFactory: (sp) => FakeServiceImplementation(),
            lifetime: ServiceLifetime.transient,
          ),
        );

      var serviceProvider = collection.buildServiceProvider();
      var expectedType = FakeServiceImplementation;

      expect(
        serviceProvider.getService<FakeService>().runtimeType,
        equals(expectedType),
      );
      expect(
        serviceProvider.getService<FakeServiceImplementation>().runtimeType,
        equals(expectedType),
      );

      for (var i = 0; i < 50; i++) {
        expect(
          serviceProvider.getService<FakeService>().runtimeType,
          equals(expectedType),
        );
        expect(
          serviceProvider.getService<FakeServiceImplementation>().runtimeType,
          equals(expectedType),
        );
      }
    });
  });
}

import 'package:extensions/hosting.dart';
import 'package:test/test.dart';

import '../fakes/fake_service.dart';

void main() {
  group('CallSiteFactoryTest', () {
    test('GetService_FactoryCallSite_Transient_DoesNotFail', () {
      var collection = ServiceCollection()
        ..add(
          ServiceDescriptor.transient<FakeServiceImplementation,
              FakeServiceImplementation>(
            (sp) => FakeServiceImplementation(),
          ),
        )
        ..add(
          ServiceDescriptor.transient<FakeService, FakeService>(
            (sp) => FakeServiceImplementation(),
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

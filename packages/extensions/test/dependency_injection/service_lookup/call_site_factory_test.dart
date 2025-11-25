import 'package:extensions/src/dependency_injection/service_collection.dart';
import 'package:extensions/src/dependency_injection/service_collection_container_builder_extensions.dart';
import 'package:extensions/src/dependency_injection/service_descriptor.dart';
import 'package:extensions/src/dependency_injection/service_provider_service_extensions.dart';
import 'package:test/test.dart';

import '../fakes/fake_service.dart';

void main() {
  group('CallSiteFactoryTest', () {
    test('GetService_FactoryCallSite_Transient_DoesNotFail', () {
      var collection = ServiceCollection()
        ..add(
          ServiceDescriptor.transient<FakeServiceImplementation>(
            (sp) => FakeServiceImplementation(),
          ),
        )
        ..add(
          ServiceDescriptor.transient<FakeService>(
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

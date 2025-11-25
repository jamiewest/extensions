import 'package:extensions/dependency_injection.dart';
import 'package:extensions/src/system/exceptions/invalid_operation_exception.dart';
import 'package:test/test.dart';

import 'fakes/fake_service.dart';

void main() {
    group('ServiceCollectionTests', () {
      test('TestMakeReadOnly', () {
        var descriptor = ServiceDescriptor(
          serviceType: FakeService,
          implementationInstance: FakeServiceImplementation(),
        );
        var serviceCollection = ServiceCollection()
          ..add(descriptor)
          ..makeReadOnly();

      var descriptor2 = ServiceDescriptor(
        serviceType: FakeEveryService,
        implementationInstance: FakeServiceImplementation(),
      );

      expect(() => serviceCollection[0] = descriptor2,
          throwsA(const TypeMatcher<InvalidOperationException>()));
      expect(() => serviceCollection.clear(),
          throwsA(const TypeMatcher<InvalidOperationException>()));
      expect(() => serviceCollection.remove(descriptor),
          throwsA(const TypeMatcher<InvalidOperationException>()));
      expect(() => serviceCollection.add(descriptor),
          throwsA(const TypeMatcher<InvalidOperationException>()));
      expect(() => serviceCollection.insert(0, descriptor2),
          throwsA(const TypeMatcher<InvalidOperationException>()));
      expect(() => serviceCollection.removeAt(0),
          throwsA(const TypeMatcher<InvalidOperationException>()));

      expect(serviceCollection.isReadOnly, isTrue);
      expect(serviceCollection.length, equals(1));
      for (var d in serviceCollection) {
        expect(d, equals(descriptor));
      }
      expect(serviceCollection[0], equals(descriptor));
      expect(serviceCollection.indexOf(descriptor), equals(0));

      // ServiceDescriptor[] copyArray = new ServiceDescriptor[1];
      // serviceCollection.CopyTo(copyArray, 0);
      // Assert.Equal(descriptor, copyArray[0]);

      serviceCollection.makeReadOnly();
      expect(serviceCollection.isReadOnly, isTrue);
    });
  });
}

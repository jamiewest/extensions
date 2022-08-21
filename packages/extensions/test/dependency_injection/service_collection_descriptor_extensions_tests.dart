import 'package:extensions/dependency_injection.dart';
import 'package:test/test.dart';

import 'fakes/factory_service.dart';
import 'fakes/fake_service.dart';

void main() {
  group('ServiceCollectionDescriptorExtensionsTest', () {
    test('Add_AddsDescriptorToServiceDescriptors', () {
      // Arrange
      var serviceCollection = ServiceCollection();
      var descriptor = ServiceDescriptor.singleton<FakeService>(
        (_) => FakeServiceImplementation(),
      );

      // Act
      serviceCollection.add(descriptor);

      // Assert
      expect(serviceCollection.length, equals(1));
      var result = serviceCollection.first;
      expect(result, equals(descriptor));
    });

    test('Add_AddsMultipleDescriptorToServiceDescriptors', () {
      // Arrange
      var serviceCollection = ServiceCollection();
      var descriptor1 = ServiceDescriptor.singleton<FakeService>(
        (_) => FakeServiceImplementation(),
      );
      var descriptor2 = ServiceDescriptor.transient<FactoryService>(
        (sp) => TransientFactoryService(),
      );

      // Act
      serviceCollection
        ..add(descriptor1)
        ..add(descriptor2);

      // Assert
      expect(serviceCollection.length, equals(2));
      expect(
        ServiceCollection()..addAll([descriptor1, descriptor2]),
        equals(serviceCollection),
      );
    });

    test('ServiceDescriptors_AllowsRemovingPreviousRegisteredServices', () {
      // Arrange
      var serviceCollection = ServiceCollection();
      var descriptor1 = ServiceDescriptor.singleton<FakeService>(
        (_) => FakeServiceImplementation(),
      );
      var descriptor2 = ServiceDescriptor.transient<FactoryService>(
        (s) => TransientFactoryService(),
      );

      // Act
      serviceCollection
        ..add(descriptor1)
        ..add(descriptor2)
        ..remove(descriptor1);

      // Assert
      var result = serviceCollection.first;
      expect(descriptor2, equals(result));
    });
  });
}

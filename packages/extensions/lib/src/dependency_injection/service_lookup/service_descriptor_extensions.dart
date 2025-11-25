import '../service_descriptor.dart';

extension ServiceDescriptorExtensions on ServiceDescriptor {
  bool hasImplementationInstance() => getImplementationInstance() != null;
  bool hasImplementationFactory() => getImplementationFactory() != null;

  Object? getImplementationInstance() =>
      isKeyedService ? keyedImplementationInstance : implementationInstance;

  Object? getImplementationFactory() =>
      isKeyedService ? keyedImplementationFactory : implementationFactory;
}

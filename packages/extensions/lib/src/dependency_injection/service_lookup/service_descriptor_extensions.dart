import 'package:extensions/hosting.dart';

extension ServiceDescriptorExtensions on ServiceDescriptor {
  bool hasImplementationInstance() => getImplementationInstance() != null;
  bool hasImplementationFactory() => getImplementationFactory() != null;

  Object? getImplementationInstance() {
    return isKeyedService
        ? keyedImplementationInstance
        : implementationInstance;
  }

  Object? getImplementationFactory() {
    return isKeyedService ? keyedImplementationFactory : implementationFactory;
  }
}

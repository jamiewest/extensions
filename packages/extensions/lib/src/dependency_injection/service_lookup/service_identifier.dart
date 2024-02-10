import '../service_descriptor.dart';

class ServiceIdentifier {
  final Object? _serviceKey;
  final Type _serviceType;

  ServiceIdentifier({
    required Type serviceType,
    Object? serviceKey,
  })  : _serviceKey = serviceKey,
        _serviceType = serviceType;

  Object? get serviceKey => _serviceKey;

  Type get serviceType => _serviceType;

  static ServiceIdentifier fromServiceType(Type serviceType) =>
      ServiceIdentifier(serviceType: serviceType);

  static ServiceIdentifier fromDescriptor(
    ServiceDescriptor serviceDescriptor,
  ) =>
      ServiceIdentifier(
        serviceType: serviceDescriptor.serviceType,
        serviceKey: serviceDescriptor.serviceKey,
      );

  @override
  bool operator ==(Object other) {
    if (other is ServiceIdentifier) {
      if (serviceKey == null && other.serviceKey == null) {
        return serviceType == other.serviceType;
      } else if (serviceKey != null && other.serviceKey != null) {
        return serviceType == other.serviceType &&
            serviceKey == other.serviceKey;
      }
    }
    return false;
  }

  @override
  int get hashCode {
    if (serviceKey == null) {
      return serviceType.hashCode;
    }
    return (serviceType.hashCode * 397) ^ serviceKey.hashCode;
  }

  @override
  String toString() {
    if (serviceKey == null) {
      return serviceType.toString();
    }
    return '($serviceType, $serviceKey)';
  }
}

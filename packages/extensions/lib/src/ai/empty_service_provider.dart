import '../dependency_injection/keyed_service_provider.dart';
import '../dependency_injection/service_provider.dart';

/// Provides an implementation of [ServiceProvider] that contains no services.
class EmptyServiceProvider implements KeyedServiceProvider {
  static final EmptyServiceProvider instance = EmptyServiceProvider();

  @override
  Object? getKeyedServiceFromType(Type serviceType, Object? serviceKey) => null;

  @override
  Object getRequiredKeyedServiceFromType(Type serviceType, Object? serviceKey) {
    throw StateError(
      'No service for type \'$serviceType\' has been registered.',
    );
  }

  @override
  Object? getServiceFromType(Type type) => null;
}

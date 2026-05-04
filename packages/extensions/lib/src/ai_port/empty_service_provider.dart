/// Provides an implementation of [ServiceProvider] that contains no services.
class EmptyServiceProvider implements KeyedServiceProvider {
  EmptyServiceProvider();

  /// Gets a singleton instance of [EmptyServiceProvider].
  static final EmptyServiceProvider instance;

  @override
  Object? getService(Type serviceType) {
    return null;
  }

  @override
  Object? getKeyedService(Type serviceType, Object? serviceKey, ) {
    return null;
  }

  @override
  Object getRequiredKeyedService(Type serviceType, Object? serviceKey, ) {
    return getKeyedService(serviceType, serviceKey) ??
        throw invalidOperationException('No service for type '${serviceType}' and key '${serviceKey}' has been registered.');
  }
}

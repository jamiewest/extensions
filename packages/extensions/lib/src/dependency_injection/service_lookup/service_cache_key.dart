import 'service_identifier.dart';

class ServiceCacheKey {
  ServiceCacheKey(this.serviceIdentifier, this.slot);

  /// Type of service being cached
  final ServiceIdentifier serviceIdentifier;

  /// Reverse index of the service when resolved in an `Iterable`
  /// where default instance gets slot 0.
  /// For example for service collection
  ///  IService Impl1
  ///  IService Impl2
  ///  IService Impl3
  /// We would get the following cache keys:
  ///  Impl1 2
  ///  Impl2 1
  ///  Impl3 0
  final int slot;

  @override
  bool operator ==(Object other) {
    if (other is ServiceCacheKey) {
      return serviceIdentifier == other.serviceIdentifier && slot == other.slot;
    }
    return false;
  }

  @override
  int get hashCode => (serviceIdentifier.hashCode * 397) ^ slot;
}

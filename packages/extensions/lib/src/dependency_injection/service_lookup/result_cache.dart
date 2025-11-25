part of 'service_lookup.dart';

class ResultCache {
  static ResultCache none(Type serviceType) {
    var cacheKey =
        ServiceCacheKey(ServiceIdentifier.fromServiceType(serviceType), 0);
    return ResultCache._(CallSiteResultCacheLocation.none, cacheKey);
  }

  ResultCache._(
    this.location,
    this.key,
  );

  factory ResultCache(
    ServiceLifetime lifetime,
    ServiceIdentifier serviceIdentifier,
    int slot,
  ) {
    CallSiteResultCacheLocation location;

    switch (lifetime) {
      case ServiceLifetime.singleton:
        location = CallSiteResultCacheLocation.root;
      case ServiceLifetime.scoped:
        location = CallSiteResultCacheLocation.scope;
      case ServiceLifetime.transient:
        location = CallSiteResultCacheLocation.dispose;
    }

    return ResultCache._(
      location,
      ServiceCacheKey(serviceIdentifier, slot),
    );
  }

  CallSiteResultCacheLocation location;

  ServiceCacheKey key;
}

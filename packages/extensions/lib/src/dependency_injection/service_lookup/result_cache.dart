import 'package:extensions/src/dependency_injection/service_lookup/service_identifier.dart';

import '../service_lifetime.dart';
import 'call_site_result_cache_location.dart';
import 'service_cache_key.dart';

class ResultCache {
  static ResultCache none(Type serviceType) {
    var cacheKey =
        ServiceCacheKey(ServiceIdentifier.fromServiceType(serviceType), 0);
    return ResultCache(CallSiteResultCacheLocation.none, cacheKey);
  }

  ResultCache(
    this.location,
    this.key,
  );

  factory ResultCache.fromServiceLifetime(
    ServiceLifetime lifetime,
    ServiceIdentifier serviceIdentifier,
    int slot,
  ) {
    CallSiteResultCacheLocation location;

    switch (lifetime) {
      case ServiceLifetime.singleton:
        location = CallSiteResultCacheLocation.root;
        break;
      case ServiceLifetime.scoped:
        location = CallSiteResultCacheLocation.scope;
        break;
      case ServiceLifetime.transient:
        location = CallSiteResultCacheLocation.dispose;
        break;
      default:
        location = CallSiteResultCacheLocation.none;
        break;
    }

    return ResultCache(
      location,
      ServiceCacheKey(serviceIdentifier, slot),
    );
  }

  CallSiteResultCacheLocation location;
  ServiceCacheKey key;
}

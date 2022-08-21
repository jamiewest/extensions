import '../service_lifetime.dart';
import 'call_site_result_cache_location.dart';
import 'service_cache_key.dart';

class ResultCache {
  static ResultCache get none => ResultCache(
        CallSiteResultCacheLocation.none,
        ServiceCacheKey.empty,
      );

  ResultCache(
    this.location,
    this.key,
  );

  factory ResultCache.builder(
    ServiceLifetime lifetime,
    Type? type,
    int slot,
  ) {
    assert(lifetime == ServiceLifetime.transient || type != null);
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
      ServiceCacheKey(type, slot),
    );
  }

  final CallSiteResultCacheLocation location;
  final ServiceCacheKey key;
}

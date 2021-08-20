import '../service_lifetime.dart';
import 'call_site_result_cache_location.dart';
import 'service_cache_kind.dart';

class ResultCache {
  static ResultCache get none => ResultCache(
        CallSiteResultCacheLocation.none,
        ServiceCacheKey.empty,
      );

  ResultCache(
    this.location,
    this.key,
  );

  factory ResultCache.fromServiceLifetime(
    ServiceLifetime lifetime,
    Type? type,
    int slot,
  ) {
    assert(lifetime == ServiceLifetime.transient || type != null);
    CallSiteResultCacheLocation location;
    if (lifetime == ServiceLifetime.singleton) {
      location = CallSiteResultCacheLocation.root;
    } else if (lifetime == ServiceLifetime.scoped) {
      location = CallSiteResultCacheLocation.scope;
    } else if (lifetime == ServiceLifetime.transient) {
      location = CallSiteResultCacheLocation.dispose;
    } else {
      location = CallSiteResultCacheLocation.none;
    }

    return ResultCache(location, ServiceCacheKey(type, slot));
  }

  final CallSiteResultCacheLocation location;
  final ServiceCacheKey key;
}

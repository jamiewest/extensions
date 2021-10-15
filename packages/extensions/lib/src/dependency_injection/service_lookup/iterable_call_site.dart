import 'call_site_kind.dart';
import 'result_cache.dart';
import 'service_call_site.dart';

class IterableCallSite extends ServiceCallSite {
  final Type _itemType;
  final Iterable<ServiceCallSite> _serviceCallSites;

  IterableCallSite(
    ResultCache cache,
    Type itemType,
    Iterable<ServiceCallSite> serviceCallSites,
  )   : _itemType = itemType,
        _serviceCallSites = serviceCallSites,
        super(cache);

  Type get itemType => _itemType;
  Iterable<ServiceCallSite> get serviceCallSites => _serviceCallSites;

  @override
  Type get serviceType => throw UnimplementedError();

  @override
  Type? get implementationType => const Iterable.empty().runtimeType;

  @override
  CallSiteKind get kind => CallSiteKind.iterable;
}

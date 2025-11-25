import 'call_site_kind.dart';
import 'service_call_site.dart';

class IterableCallSite extends ServiceCallSite {
  final Type _serviceType;
  final Type? _itemType;
  final Iterable<ServiceCallSite> _serviceCallSites;

  IterableCallSite(
    super.cache,
    Type serviceType,
    Type? itemType,
    Iterable<ServiceCallSite> serviceCallSites,
  )   : _itemType = itemType,
        _serviceType = serviceType,
        _serviceCallSites = serviceCallSites;

  Type? get itemType => _itemType;
  Iterable<ServiceCallSite> get serviceCallSites => _serviceCallSites;

  @override
  Type get serviceType => _serviceType;

  @override
  Type? get implementationType => const [Iterable<dynamic>.empty()].runtimeType;

  @override
  CallSiteKind get kind => CallSiteKind.iterable;
}

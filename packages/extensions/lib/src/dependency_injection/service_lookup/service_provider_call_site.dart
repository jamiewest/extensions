import '../service_provider.dart';
import 'call_site_kind.dart';
import 'service_call_site.dart';
import 'service_lookup.dart';

class ServiceProviderCallSite extends ServiceCallSite {
  ServiceProviderCallSite() : super(ResultCache.none(ServiceProvider));

  @override
  Type get serviceType => ServiceProvider;

  @override
  Type? get implementationType => ServiceProvider;

  @override
  CallSiteKind get kind => CallSiteKind.serviceProvider;
}

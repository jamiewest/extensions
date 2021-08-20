import '../service_scope_factory.dart';
import 'call_site_kind.dart';
import 'result_cache.dart';
import 'service_call_site.dart';
import 'service_provider_engine.dart';

class ServiceScopeFactoryCallSite extends ServiceCallSite {
  ServiceScopeFactoryCallSite(this.value) : super(ResultCache.none);

  ServiceScopeFactory value;

  @override
  Type get serviceType => ServiceScopeFactory;

  @override
  Type? get implementationType => ServiceProviderEngine;

  @override
  CallSiteKind get kind => CallSiteKind.serviceScopeFactory;
}

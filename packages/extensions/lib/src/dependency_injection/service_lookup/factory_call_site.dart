import 'call_site_kind.dart';
import 'service_call_site.dart';

class FactoryCallSite extends ServiceCallSite {
  final Function _factory;
  final Type _serviceType;

  FactoryCallSite(
    super.cache,
    Type serviceType,
    Function factory,
  )   : _factory = factory,
        _serviceType = serviceType;

  Function get factory => _factory;

  @override
  Type get serviceType => _serviceType;

  @override
  Type? get implementationType => null;

  @override
  CallSiteKind get kind => CallSiteKind.factory;
}

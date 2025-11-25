import '../service_provider.dart';
import 'call_site_kind.dart';
import 'service_call_site.dart';
import 'service_lookup.dart';

typedef FactoryCallback = Object Function(
  ServiceProvider services,
);

class FactoryCallSite extends ServiceCallSite {
  final FactoryCallback _factory;
  final Type _serviceType;

  FactoryCallSite(
    super.cache,
    Type serviceType,
    FactoryCallback factory,
  )   : _factory = factory,
        _serviceType = serviceType;

  factory FactoryCallSite.keyed(
    ResultCache cache,
    Type serviceType,
    Object serviceKey,
    Object Function(ServiceProvider serviceProvider, Object serviceKey) factory,
  ) => FactoryCallSite(
      cache,
      serviceType,
      (sp) => factory(sp, serviceKey),
    );

  FactoryCallback get factory => _factory;

  @override
  Type get serviceType => _serviceType;

  @override
  Type? get implementationType => null;

  @override
  CallSiteKind get kind => CallSiteKind.factory;
}

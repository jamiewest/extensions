import 'service_call_site.dart';
import 'service_lookup.dart';

abstract class ServiceProviderEngine {
  CreateServiceAccessorInner realizeService(
    ServiceCallSite callSite,
  );
}

import '../service_provider.dart';
import 'service_call_site.dart';

abstract class ServiceProviderEngine {
  CreateServiceAccessorInner realizeService(ServiceCallSite callSite);
}

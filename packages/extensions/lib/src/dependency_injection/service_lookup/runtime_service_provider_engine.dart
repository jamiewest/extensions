import '../service_provider.dart';
import 'service_call_site.dart';
import 'service_provider_engine.dart';

class RuntimeServiceProviderEngine extends ServiceProviderEngine {
  static RuntimeServiceProviderEngine get instance =>
      RuntimeServiceProviderEngine();
  @override
  CreateServiceAccessorInner realizeService(ServiceCallSite callSite) =>
      (scope) => CallSiteRuntimeResolver.instance.resolve(callSite, scope);
}

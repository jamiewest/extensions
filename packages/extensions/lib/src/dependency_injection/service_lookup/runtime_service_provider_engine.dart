import '../service_provider_impl.dart';
import 'call_site_runtime_resolver.dart';
import 'service_call_site.dart';
import 'service_provider_engine.dart';

class RuntimeServiceProviderEngine extends ServiceProviderEngine {
  static RuntimeServiceProviderEngine get instance =>
      RuntimeServiceProviderEngine();
  @override
  CreateServiceAccessorInner realizeService(ServiceCallSite callSite) =>
      (scope) => CallSiteRuntimeResolver.instance.resolve(
            callSite,
            scope,
          );
}

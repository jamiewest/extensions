import '../../../dependency_injection.dart';
import '../../system/exceptions/invalid_operation_exception.dart';
import 'call_site_visitor.dart';
import 'constant_call_site.dart';
import 'factory_call_site.dart';
import 'iterable_call_site.dart';
import 'service_cache_key.dart';
import 'service_call_site.dart';
import 'service_provider_call_site.dart';

class CallSiteValidator extends CallSiteVisitor<CallSiteValidatorState, Type?> {
  final Map<ServiceCacheKey, Type> _scopedServices = <ServiceCacheKey, Type>{};

  void validateCallSite(ServiceCallSite callSite) {
    var scoped = visitCallSite(callSite, CallSiteValidatorState());
    if (scoped != null) {
      _scopedServices[callSite.cache.key] = scoped;
    }
  }

  void validateResolution(
    ServiceCallSite callSite,
    ServiceScope scope,
    ServiceScope rootScope,
  ) {
    if (scope == rootScope && _scopedServices.containsKey(callSite.cache.key)) {
      var scopedService = _scopedServices[callSite.cache.key];
      var serviceType = callSite.serviceType;
      if (serviceType == scopedService) {
        throw InvalidOperationException(
          message: 'Cannot resolve {1} service \'{0}\' from root provider.',
        );
      }
      throw InvalidOperationException(
        message: 'Cannot resolve \'{0}\' from root provider because'
            ' it requires {2} service \'{1}\'.',
      );
    }
  }

  @override
  Type? visitIterable(
    IterableCallSite iterableCallSite,
    CallSiteValidatorState argument,
  ) {
    Type? result;
    for (var serviceCallSite in iterableCallSite.serviceCallSites) {
      var scoped = visitCallSite(serviceCallSite, argument);
      result ??= scoped;
    }

    return result;
  }

  @override
  Type? visitRootCache(
    ServiceCallSite callSite,
    CallSiteValidatorState argument,
  ) {
    argument.singleton = callSite;
    return visitCallSiteMain(callSite, argument);
  }

  @override
  Type? visitScopeCache(
    ServiceCallSite callSite,
    CallSiteValidatorState argument,
  ) {
    // We are fine with having ServiceScopeService requested by singletons
    if (callSite.serviceType is ServiceScopeFactory) {
      return null;
    }
    if (argument.singleton != null) {
      throw InvalidOperationException(
        message: 'Cannot consume scoped service \'${callSite.serviceType}\''
            ' from singleton \'${argument.singleton!.serviceType}\'',
      );
    }

    visitCallSiteMain(callSite, argument);
    return callSite.serviceType;
  }

  @override
  Type? visitConstant(
    ConstantCallSite constantCallSite,
    CallSiteValidatorState argument,
  ) =>
      null;

  @override
  Type? visitFactory(
    FactoryCallSite factoryCallSite,
    CallSiteValidatorState argument,
  ) =>
      null;

  @override
  Type? visitServiceProvider(
    ServiceProviderCallSite serviceProviderCallSite,
    CallSiteValidatorState argument,
  ) =>
      null;
}

class CallSiteValidatorState {
  ServiceCallSite? singleton;
}

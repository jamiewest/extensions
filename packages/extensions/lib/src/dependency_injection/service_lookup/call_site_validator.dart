import '../../../dependency_injection.dart';
import '../service_scope.dart';
import 'call_site_visitor.dart';
import 'constant_call_site.dart';
import 'factory_call_site.dart';
import 'iterable_call_site.dart';
import 'service_call_site.dart';
import 'service_provider_call_site.dart';

class CallSiteValidator extends CallSiteVisitor<CallSiteValidatorState, Type?> {
  final Map<Type, Type> _scopedServices = <Type, Type>{};

  void validateCallSite(ServiceCallSite callSite) {
    var scoped = visitCallSite(callSite, CallSiteValidatorState());
    if (scoped != null) {
      _scopedServices[callSite.serviceType] = scoped;
    }
  }

  void validateResolution(
    Type serviceType,
    ServiceScope scope,
    ServiceScope rootScope,
  ) {
    if (scope == rootScope && _scopedServices.containsKey(serviceType)) {
      var scopedService = _scopedServices[serviceType];
      if (serviceType == scopedService) {
        throw Exception('DirectScopedResolvedFromRootException');
      }
      throw Exception('ScopedResolvedFromRootException');
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
    if (callSite is ServiceScopeFactory) {
      return null;
    }

    if (argument.singleton != null) {
      // throw new InvalidOperationException(SR.Format(
      //     SR.ScopedInSingletonException,
      //     scopedCallSite.ServiceType,
      //     state.Singleton.ServiceType,
      //     nameof(ServiceLifetime.Scoped).ToLowerInvariant(),
      //     nameof(ServiceLifetime.Singleton).ToLowerInvariant()));
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

import '../service_scope.dart';
import 'call_site_visitor.dart';
import 'constant_call_site.dart';
import 'factory_call_site.dart';
import 'iterable_call_site.dart';
import 'service_call_site.dart';
import 'service_provider_call_site.dart';
import 'service_scope_factory_call_site.dart';

class CallSiteValidator extends CallSiteVisitor<CallSiteValidatorState, Type> {
  final Map<Type, Type> _scopedServices = <Type, Type>{};

  void validateCallSite(ServiceCallSite callSite) {
    var scoped = visitCallSite(callSite, CallSiteValidatorState());
    _scopedServices[callSite.serviceType] = scoped;
  }

  void validateResolution(
    Type serviceType,
    ServiceScope scope,
    ServiceScope rootScope,
  ) {}

  @override
  Type visitIterable(
    IterableCallSite iterableCallSite,
    CallSiteValidatorState argument,
  ) {
    Type? result;
    for (var serviceCallSite in iterableCallSite.serviceCallSites) {
      var scoped = visitCallSite(serviceCallSite, argument);
      result ??= scoped;
    }

    return result!;
  }

  @override
  Type visitRootCache(
      ServiceCallSite callSite, CallSiteValidatorState argument) {
    argument.singleton = callSite;
    return visitCallSiteMain(callSite, argument);
  }

  @override
  Type visitScopeCache(
      ServiceCallSite callSite, CallSiteValidatorState argument) {
    if (callSite is ServiceScopeFactoryCallSite) {
      //return null;
    }

    visitCallSiteMain(callSite, argument);
    return callSite.serviceType;
  }

  @override
  Type visitConstant(
    ConstantCallSite constantCallSite,
    CallSiteValidatorState argument,
  ) {
    throw UnimplementedError();
  }

  @override
  Type visitFactory(
    FactoryCallSite factoryCallSite,
    CallSiteValidatorState argument,
  ) {
    throw UnimplementedError();
  }

  @override
  Type visitServiceProvider(
    ServiceProviderCallSite serviceProviderCallSite,
    CallSiteValidatorState argument,
  ) {
    throw UnimplementedError();
  }

  @override
  Type visitServiceScopeFactory(
    ServiceScopeFactoryCallSite serviceScopeFactoryCallSite,
    CallSiteValidatorState argument,
  ) {
    throw UnimplementedError();
  }
}

class CallSiteValidatorState {
  ServiceCallSite? singleton;
}

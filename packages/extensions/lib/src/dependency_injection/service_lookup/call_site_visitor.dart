import 'call_site_kind.dart';
import 'call_site_result_cache_location.dart';
import 'constant_call_site.dart';
import 'factory_call_site.dart';
import 'iterable_call_site.dart';
import 'service_call_site.dart';
import 'service_provider_call_site.dart';

abstract class CallSiteVisitor<TArgument, TResult> {
  TResult visitCallSite(ServiceCallSite callSite, TArgument argument) {
    switch (callSite.cache.location) {
      case CallSiteResultCacheLocation.root:
        return visitRootCache(callSite, argument);
      case CallSiteResultCacheLocation.scope:
        return visitScopeCache(callSite, argument);
      case CallSiteResultCacheLocation.dispose:
        return visitDisposeCache(callSite, argument);
      case CallSiteResultCacheLocation.none:
        return visitNoCache(callSite, argument);
    }
  }

  TResult visitCallSiteMain(ServiceCallSite callSite, TArgument argument) {
    switch (callSite.kind) {
      case CallSiteKind.factory:
        return visitFactory(callSite as FactoryCallSite, argument);
      case CallSiteKind.iterable:
        return visitIterable(callSite as IterableCallSite, argument);
      case CallSiteKind.constant:
        return visitConstant(callSite as ConstantCallSite, argument);
      case CallSiteKind.serviceProvider:
        return visitServiceProvider(
            callSite as ServiceProviderCallSite, argument);
    }
  }

  TResult visitNoCache(
    ServiceCallSite callSite,
    TArgument argument,
  ) =>
      visitCallSiteMain(
        callSite,
        argument,
      );

  TResult visitDisposeCache(
    ServiceCallSite callSite,
    TArgument argument,
  ) =>
      visitCallSiteMain(
        callSite,
        argument,
      );

  TResult visitRootCache(
    ServiceCallSite callSite,
    TArgument argument,
  ) =>
      visitCallSiteMain(
        callSite,
        argument,
      );

  TResult visitScopeCache(
    ServiceCallSite callSite,
    TArgument argument,
  ) =>
      visitCallSiteMain(
        callSite,
        argument,
      );

  TResult visitConstant(
    ConstantCallSite constantCallSite,
    TArgument argument,
  );

  TResult visitServiceProvider(
    ServiceProviderCallSite serviceProviderCallSite,
    TArgument argument,
  );

  TResult visitIterable(
    IterableCallSite iterableCallSite,
    TArgument argument,
  );

  TResult visitFactory(
    FactoryCallSite factoryCallSite,
    TArgument argument,
  );
}

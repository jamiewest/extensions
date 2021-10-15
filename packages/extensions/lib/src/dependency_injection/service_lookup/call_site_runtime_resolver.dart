// import 'call_site_visitor.dart';
// import 'constant_call_site.dart';
// import 'factory_call_site.dart';
// import 'iterable_call_site.dart';
// import 'service_call_site.dart';
// import 'service_provider_call_site.dart';
// import 'service_provider_engine_scope.dart';
// import 'service_scope_factory_call_site.dart';

// class CallSiteRuntimeResolver
//     extends CallSiteVisitor<RuntimeResolverContext, Object> {
//   static CallSiteRuntimeResolver get instance => CallSiteRuntimeResolver();

//   Object? resolve(
//     ServiceCallSite callSite,
//     ServiceProviderEngineScope scope,
//   ) =>
//       visitCallSite(
//         callSite,
//         RuntimeResolverContext(scope: scope),
//       );

//   @override
//   Object visitDisposeCache(
//     ServiceCallSite callSite,
//     RuntimeResolverContext argument,
//   ) =>
//       argument.scope!.captureDisposable(
//         visitCallSiteMain(callSite, argument),
//       );

//   @override
//   Object visitRootCache(
//     ServiceCallSite callSite,
//     RuntimeResolverContext argument,
//   ) =>
//       resolveService(
//         callSite,
//         argument,
//         argument.scope!.rootProvider._root,
//       );

//   @override
//   Object visitScopeCache(
//     ServiceCallSite callSite,
//     RuntimeResolverContext argument,
//   ) =>
//       argument.scope! == argument.scope!.rootProvider._root
//           ? visitRootCache(callSite, argument)
//           : _visitCache(
//               callSite,
//               argument,
//               argument.scope!,
//             );

//   Object _visitCache(
//     ServiceCallSite callSite,
//     RuntimeResolverContext argument,
//     ServiceProviderEngineScope serviceProviderEngine,
//   ) =>
//       resolveService(
//         callSite,
//         argument,
//         serviceProviderEngine,
//       );

//   Object resolveService(
//     ServiceCallSite callSite,
//     RuntimeResolverContext context,
//     ServiceProviderEngineScope serviceProviderEngine,
//   ) {
//     var resolvedServices = serviceProviderEngine.resolvedServices;

//     Object? resolved;
//     if (resolvedServices.containsKey(callSite.cache.key)) {
//       return resolvedServices[callSite.cache.key]!;
//     }

//     resolved = visitCallSiteMain(
//         callSite,
//         RuntimeResolverContext(
//           scope: serviceProviderEngine,
//           acquiredLocks: context.acquiredLocks,
//         ));
//     serviceProviderEngine.captureDisposable(resolved);
//     serviceProviderEngine.resolvedServices[callSite.cache.key] = resolved;
//     return resolved;
//   }

//   @override
//   Object visitConstant(
//     ConstantCallSite constantCallSite,
//     RuntimeResolverContext argument,
//   ) =>
//       constantCallSite.defaultValue!;

//   @override
//   Object visitServiceProvider(
//     ServiceProviderCallSite serviceProviderCallSite,
//     RuntimeResolverContext argument,
//   ) =>
//       argument.scope!;

//   @override
//   Object visitServiceScopeFactory(
//     ServiceScopeFactoryCallSite serviceScopeFactoryCallSite,
//     RuntimeResolverContext argument,
//   ) =>
//       serviceScopeFactoryCallSite.value;

//   @override
//   Object visitIterable(
//     IterableCallSite iterableCallSite,
//     RuntimeResolverContext argument,
//   ) {
//     var items = [];
//     for (var i = 0; i < iterableCallSite.serviceCallSites.length; i++) {
//       var value = visitCallSite(
//           iterableCallSite.serviceCallSites.elementAt(i), argument);
//       items.add(value);
//     }
//     return items;
//   }

//   @override
//   Object visitFactory(
//     FactoryCallSite factoryCallSite,
//     RuntimeResolverContext argument,
//   ) =>
//       factoryCallSite.factory(argument.scope!) as Object;
// }

// class RuntimeResolverContext {
//   RuntimeResolverContext({
//     this.scope,
//     this.acquiredLocks,
//   });

//   ServiceProviderEngineScope? scope;
//   RuntimeResolverLock? acquiredLocks;
// }

// enum RuntimeResolverLock { scope, root }

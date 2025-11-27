part of 'service_lookup.dart';

class CallSiteRuntimeResolver
    extends CallSiteVisitor<RuntimeResolverContext, Object?> {
  static CallSiteRuntimeResolver get instance => CallSiteRuntimeResolver();

  Object? resolve(
    ServiceCallSite callSite,
    ServiceProviderEngineScope scope,
  ) {
    if (scope.isRootScope && callSite.value is Object) {
      if (callSite.value != null) {
        return callSite.value;
      }
    }

    return visitCallSite(
      callSite,
      RuntimeResolverContext(
        scope: scope,
        callSiteChain: scope._resolutionChain,
      ),
    );
  }

  @override
  Object? visitDisposeCache(
    ServiceCallSite callSite,
    RuntimeResolverContext argument,
  ) =>
      argument.scope!.captureDisposable(
        visitCallSiteMain(callSite, argument),
      );

  @override
  Object? visitRootCache(
    ServiceCallSite callSite,
    RuntimeResolverContext argument,
  ) {
    if (callSite.value is Object) {
      if (callSite.value != null) {
        return callSite.value!;
      }
    }

    final serviceProviderEngine = argument.scope!.rootProvider._root;

    final resolved = visitCallSiteMain(
        callSite,
        RuntimeResolverContext(
          scope: serviceProviderEngine,
          acquiredLocks: argument.acquiredLocks,
          callSiteChain: argument.callSiteChain,
        ));

    serviceProviderEngine.captureDisposable(resolved);
    callSite.value = resolved;
    return resolved;
  }

  @override
  Object? visitScopeCache(
    ServiceCallSite callSite,
    RuntimeResolverContext argument,
  ) =>
      argument.scope!.isRootScope
          ? visitRootCache(callSite, argument)
          : _visitCache(
              callSite,
              argument,
              argument.scope!,
            );

  Object? _visitCache(
    ServiceCallSite callSite,
    RuntimeResolverContext argument,
    ServiceProviderEngineScope serviceProviderEngine,
  ) {
    final resolvedServices = serviceProviderEngine.resolvedServices;

    Object? resolved;
    if (resolvedServices.containsKey(callSite.cache.key)) {
      return resolvedServices[callSite.cache.key]!;
    }

    resolved = visitCallSiteMain(
        callSite,
        RuntimeResolverContext(
          scope: serviceProviderEngine,
          acquiredLocks: argument.acquiredLocks,
          callSiteChain: argument.callSiteChain,
        ));
    serviceProviderEngine.captureDisposable(resolved);
    resolvedServices[callSite.cache.key] = resolved;
    return resolved;
  }

  @override
  Object visitConstant(
    ConstantCallSite constantCallSite,
    RuntimeResolverContext argument,
  ) =>
      constantCallSite.defaultValue!;

  @override
  Object visitServiceProvider(
    ServiceProviderCallSite serviceProviderCallSite,
    RuntimeResolverContext argument,
  ) =>
      argument.scope!;

  @override
  Object visitIterable(
    IterableCallSite iterableCallSite,
    RuntimeResolverContext argument,
  ) {
    var items = <Object?>[];
    for (var i = 0; i < iterableCallSite.serviceCallSites.length; i++) {
      var value = visitCallSite(
        iterableCallSite.serviceCallSites.elementAt(i),
        argument,
      );

      items.add(value);
    }
    return items;
  }

  @override
  Object visitFactory(
    FactoryCallSite factoryCallSite,
    RuntimeResolverContext argument,
  ) {
    final serviceIdentifier = ServiceIdentifier(
      serviceType: factoryCallSite.serviceType,
      serviceKey: factoryCallSite.key,
    );

    try {
      argument.callSiteChain
        ..checkCircularDependency(serviceIdentifier)
        ..add(serviceIdentifier);

      return factoryCallSite.factory(argument.scope!);
    } finally {
      argument.callSiteChain.remove(serviceIdentifier);
    }
  }

  // @override
  // Object visitServiceScopeFactory(
  //   ServiceScopeFactoryCallSite serviceScopeFactoryCallSite,
  //   RuntimeResolverContext argument,
  // ) =>
  //     serviceScopeFactoryCallSite.value;
}

class RuntimeResolverContext {
  RuntimeResolverContext({
    this.scope,
    this.acquiredLocks,
    CallSiteChain? callSiteChain,
  }) : callSiteChain = callSiteChain ?? CallSiteChain();

  ServiceProviderEngineScope? scope;
  RuntimeResolverLock? acquiredLocks;
  CallSiteChain callSiteChain;
}

enum RuntimeResolverLock { scope, root }

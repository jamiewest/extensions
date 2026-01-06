part of 'service_lookup.dart';

class CallSiteFactory
    implements ServiceProviderIsService, ServiceProviderIsKeyedService {
  final int defaultslot = 0;
  final List<ServiceDescriptor> _descriptors;
  final Map<ServiceCacheKey, ServiceCallSite> _callSiteCache =
      <ServiceCacheKey, ServiceCallSite>{};
  final Map<ServiceIdentifier, ServiceDescriptorCacheItem> _descriptorLookup =
      <ServiceIdentifier, ServiceDescriptorCacheItem>{};

  CallSiteFactory(Iterable<ServiceDescriptor> descriptors)
      : _descriptors = descriptors.toList() {
    populate();
  }

  void populate() {
    for (var descriptor in _descriptors) {
      var cacheKey = ServiceIdentifier.fromDescriptor(descriptor);

      ServiceDescriptorCacheItem cacheItem;
      if (_descriptorLookup.containsKey(cacheKey)) {
        cacheItem = _descriptorLookup[cacheKey]!;
      } else {
        cacheItem = ServiceDescriptorCacheItem();
      }

      _descriptorLookup[cacheKey] = cacheItem.add(descriptor);
    }
  }

  int? getSlot(ServiceDescriptor serviceDescriptor) {
    final serviceIdentifier =
        ServiceIdentifier.fromDescriptor(serviceDescriptor);
    if (_descriptorLookup.containsKey(serviceIdentifier)) {
      final item = _descriptorLookup[serviceIdentifier];
      return item!.getSlot(serviceDescriptor);
    }
    return null;
  }

  ServiceCallSite? getCallSite(
    ServiceDescriptor serviceDescriptor,
    CallSiteChain callSiteChain,
  ) {
    final serviceIdentifier =
        ServiceIdentifier.fromDescriptor(serviceDescriptor);

    if (_descriptorLookup.containsKey(serviceIdentifier)) {
      var descriptor = _descriptorLookup[serviceIdentifier];
      return tryCreateExact(
        serviceDescriptor,
        serviceIdentifier,
        callSiteChain,
        descriptor!.getSlot(serviceDescriptor),
      );
    }

    return null;
  }

  void add(
      ServiceIdentifier serviceIdentifier, ServiceCallSite serviceCallSite) {
    _callSiteCache[ServiceCacheKey(serviceIdentifier, defaultslot)] =
        serviceCallSite;
  }

  ServiceCallSite? getCallSiteFromType(
    Type serviceType,
    CallSiteChain callSiteChain,
  ) {
    final serviceIdentifier = ServiceIdentifier.fromServiceType(serviceType);

    callSiteChain.checkCircularDependency(serviceIdentifier);

    if (_callSiteCache
        .containsKey(ServiceCacheKey(serviceIdentifier, defaultslot))) {
      var site =
          _callSiteCache[ServiceCacheKey(serviceIdentifier, defaultslot)];
      if (site != null) {
        return site;
      } else {
        return createCallSite(serviceIdentifier, callSiteChain);
      }
    } else {
      return createCallSite(serviceIdentifier, callSiteChain);
    }
  }

  ServiceCallSite? getCallSiteFromServiceIdentifer(
    ServiceIdentifier serviceIdentifier,
    CallSiteChain callSiteChain,
  ) {
    callSiteChain.checkCircularDependency(serviceIdentifier);

    if (_callSiteCache
        .containsKey(ServiceCacheKey(serviceIdentifier, defaultslot))) {
      var site =
          _callSiteCache[ServiceCacheKey(serviceIdentifier, defaultslot)];
      if (site != null) {
        return site;
      } else {
        return createCallSite(serviceIdentifier, callSiteChain);
      }
    } else {
      return createCallSite(serviceIdentifier, callSiteChain);
    }
  }

  ServiceCallSite? createCallSite(
    ServiceIdentifier serviceIdentifier,
    CallSiteChain callSiteChain,
  ) {
    try {
      callSiteChain
        ..checkCircularDependency(serviceIdentifier)
        ..add(serviceIdentifier);

      final callSite = _tryCreateExact(serviceIdentifier, callSiteChain) ??
          tryCreateIterable(serviceIdentifier, callSiteChain);

      return callSite;
    } finally {
      callSiteChain.remove(serviceIdentifier);
    }
  }

  ServiceCallSite? _tryCreateExact(
    ServiceIdentifier serviceIdentifier,
    CallSiteChain callSiteChain,
  ) {
    if (_descriptorLookup.containsKey(serviceIdentifier)) {
      var descriptor = _descriptorLookup[serviceIdentifier]!;

      return tryCreateExact(
        descriptor.last,
        serviceIdentifier,
        callSiteChain,
        defaultslot,
      );
    }

    if (serviceIdentifier.serviceKey != null) {
      // Check if there is a registration with KeyedService.AnyKey
      var catchAllIdentifier = ServiceIdentifier(
        serviceKey: KeyedService.anyKey,
        serviceType: serviceIdentifier.serviceType,
      );
      if (_descriptorLookup.containsKey(catchAllIdentifier)) {
        final descriptor = _descriptorLookup[catchAllIdentifier];
        return tryCreateExact(
          descriptor!.last,
          serviceIdentifier,
          callSiteChain,
          defaultslot,
        );
      }
    }
    return null;
  }

  ServiceCallSite? tryCreateIterable(
    ServiceIdentifier serviceIdentifier,
    CallSiteChain callSiteChain,
  ) {
    var callSiteKey = ServiceCacheKey(serviceIdentifier, defaultslot);
    if (_callSiteCache.containsKey(callSiteKey)) {
      return _callSiteCache[callSiteKey];
    }

    try {
      callSiteChain.add(serviceIdentifier);

      var serviceType = serviceIdentifier.serviceType;
      Type? itemType;
      if (serviceType.toString().contains('Iterable')) {
        var cacheLocation = CallSiteResultCacheLocation.root;

        var typeName = serviceType.toString().replaceFirst('Iterable', '');
        if (typeName[0] == '<') {
          typeName = typeName.substring(1, typeName.length);
        }

        if (typeName[typeName.length - 1] == '>') {
          typeName = typeName.substring(0, typeName.length - 1);
        }

        for (var descriptor in _descriptors) {
          if (descriptor.serviceType.toString() == typeName) {
            itemType = descriptor.serviceType;
            break;
          }
        }

        if (itemType == null) {
          return null;
        }

        var cacheKey = ServiceIdentifier(
          serviceKey: serviceIdentifier.serviceKey,
          serviceType: itemType,
        );

        var callSites = <ServiceCallSite>[];
        var callSitesByIndex = <MapEntry<int, ServiceCallSite>>[];

        var slot = 0;
        for (var i = _descriptors.length - 1; i >= 0; i--) {
          if (_keysMatch(_descriptors[i].serviceKey, cacheKey.serviceKey)) {
            var callSite = tryCreateExact(
              _descriptors[i],
              cacheKey,
              callSiteChain,
              slot,
            );
            if (callSite != null) {
              slot++;
              cacheLocation = _getCommonCacheLocation(
                cacheLocation,
                callSite.cache.location,
              );
              callSitesByIndex.add(MapEntry<int, ServiceCallSite>(i, callSite));
            }
          }
        }

        callSitesByIndex.sortBy<num>((e) => e.key);
        callSites.addAll(callSitesByIndex
            .map(
              (e) => e.value,
            )
            .toList());

        var resultCache = (cacheLocation == CallSiteResultCacheLocation.scope ||
                cacheLocation == CallSiteResultCacheLocation.root)
            ? ResultCache._(cacheLocation, callSiteKey)
            : ResultCache._(CallSiteResultCacheLocation.none, callSiteKey);

        return _callSiteCache[callSiteKey] = IterableCallSite(
          resultCache,
          serviceType,
          itemType,
          callSites,
        );
      } else {
        return null;
      }
    } finally {
      callSiteChain.remove(serviceIdentifier);
    }
  }

  CallSiteResultCacheLocation _getCommonCacheLocation(
    CallSiteResultCacheLocation locationA,
    CallSiteResultCacheLocation locationB,
  ) =>
      CallSiteResultCacheLocation.values[max(
        locationA.value,
        locationB.value,
      )];

  ServiceCallSite? tryCreateExact(
    ServiceDescriptor descriptor,
    ServiceIdentifier serviceIdentifier,
    CallSiteChain callSiteChain,
    int slot,
  ) {
    if (serviceIdentifier.serviceType == descriptor.serviceType) {
      var callSiteKey = ServiceCacheKey(serviceIdentifier, slot);
      if (_callSiteCache.containsKey(callSiteKey)) {
        return _callSiteCache[callSiteKey];
      }

      ServiceCallSite callSite;
      var lifetime = ResultCache(
        descriptor.lifetime,
        serviceIdentifier,
        slot,
      );

      if (descriptor.hasImplementationInstance()) {
        callSite = ConstantCallSite(
          descriptor.serviceType,
          descriptor.getImplementationInstance(),
        );
      } else if (!descriptor.isKeyedService &&
          descriptor.implementationFactory != null) {
        callSite = FactoryCallSite(
          lifetime,
          descriptor.serviceType,
          descriptor.implementationFactory!,
        );
      } else if (descriptor.isKeyedService &&
          descriptor.keyedImplementationFactory != null) {
        callSite = FactoryCallSite.keyed(
          lifetime,
          descriptor.serviceType,
          descriptor.serviceKey!,
          descriptor.keyedImplementationFactory!,
        );
      } else {
        throw InvalidOperationException(message: 'Invalid service descriptor');
      }
      callSite.key = descriptor.serviceKey;
      return _callSiteCache[callSiteKey] = callSite;
    }
    return null;
  }

  bool _isService(ServiceIdentifier serviceIdentifier) {
    var serviceType = serviceIdentifier.serviceType;

    if (_descriptorLookup.containsKey(serviceIdentifier)) {
      return true;
    }

    if (serviceIdentifier.serviceKey != null &&
        _descriptorLookup.containsKey(
          ServiceIdentifier(
            serviceKey: KeyedService.anyKey,
            serviceType: serviceType,
          ),
        )) {
      return true;
    }

    // These are the built in service types that aren't part of the list of
    // service descriptors. If you update these make sure to also update the
    // code in ServiceProvider.ctor
    return serviceType is ServiceProvider ||
        serviceType is ServiceProviderFactory ||
        serviceType is ServiceProviderIsService ||
        serviceType is ServiceProviderIsKeyedService;
  }

  @override
  bool isService(Type serviceType) => _isService(
        ServiceIdentifier(
          serviceKey: null,
          serviceType: serviceType,
        ),
      );

  @override
  bool isKeyedService(Type serviceType, Object? serviceKey) => _isService(
      ServiceIdentifier(serviceKey: serviceKey, serviceType: serviceType));
}

class ServiceDescriptorCacheItem {
  ServiceDescriptor? _item;
  List<ServiceDescriptor>? _items;

  ServiceDescriptor get last {
    if (_items != null && _items!.isNotEmpty) {
      return _items![_items!.length - 1];
    }
    assert(_item != null);
    return _item!;
  }

  ServiceDescriptor operator [](int index) {
    if (index >= length) {
      // throw error
    }
    if (index == 0) {
      return _item!;
    }
    return _items![index - 1];
  }

  int get length {
    if (_item == null) {
      assert(_items == null);
      return 0;
    }

    return 1 + (_items?.length ?? 0);
  }

  int getSlot(ServiceDescriptor descriptor) {
    if (descriptor == _item) {
      return 0;
    }

    if (_items != null) {
      var index = _items!.indexOf(descriptor);
      if (index != -1) {
        return _items!.length - (index + 1);
      }
    }

    throw InvalidOperationException(
      message: 'Requested service descriptor doesn\'t exist.',
    );
  }

  ServiceDescriptorCacheItem add(ServiceDescriptor descriptor) {
    var newCacheItem = ServiceDescriptorCacheItem();
    if (_item == null) {
      assert(_items == null);
      newCacheItem._item = descriptor;
    } else {
      newCacheItem
        .._item = _item
        .._items = _items ?? <ServiceDescriptor>[]
        .._items?.add(descriptor);
    }
    return newCacheItem;
  }
}

/// Returns true if both keys are null or equals, or if key1 is
/// KeyedService.AnyKey and key2 is not null
bool _keysMatch(
  Object? key1,
  Object? key2,
) {
  if (key1 == null && key2 == null) {
    return true;
  }

  if (key1 != null && key2 != null) {
    return key1 == key2 ||
        key1 == KeyedService.anyKey ||
        key2 == KeyedService.anyKey;
  }

  return false;
}

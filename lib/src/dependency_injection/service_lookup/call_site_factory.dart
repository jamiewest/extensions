import 'package:extensions/src/hosting/hosted_service.dart';

import '../service_descriptor.dart';
import '../service_provider.dart';
import '../service_provider_factory.dart';
import '../service_provider_is_service.dart';
import 'call_site_chain.dart';
import 'call_site_result_cache_location.dart';
import 'constant_call_site.dart';
import 'factory_call_site.dart';
import 'iterable_call_site.dart';
import 'result_cache.dart';
import 'service_cache_kind.dart';
import 'service_call_site.dart';

class CallSiteFactory implements ServiceProviderIsService {
  final int defaultslot = 0;
  final Iterable<ServiceDescriptor> _descriptors;
  final Map<Type, ServiceCallSite> _callSiteCache = <Type, ServiceCallSite>{};
  final Map<Type, ServiceDescriptorCacheItem?> _descriptorLookup =
      <Type, ServiceDescriptorCacheItem?>{};

  CallSiteFactory(Iterable<ServiceDescriptor> descriptors)
      : _descriptors = descriptors {
    populate();
  }

  void populate() {
    for (var descriptor in _descriptors) {
      var cacheKey = descriptor.serviceType;
      ServiceDescriptorCacheItem? cacheItem;
      if (_descriptorLookup.containsKey(cacheKey)) {
        cacheItem = _descriptorLookup[cacheKey];
        if (cacheItem != null) {
          cacheItem.add(descriptor);
        } else {
          cacheItem = ServiceDescriptorCacheItem().add(descriptor);
        }
      } else {
        cacheItem = ServiceDescriptorCacheItem().add(descriptor);
      }
      _descriptorLookup[cacheKey] = cacheItem;
    }
  }

  void add(Type type, ServiceCallSite serviceCallSite) {
    _callSiteCache[type] = serviceCallSite;
  }

  ServiceCallSite? getCallSiteFromType(
    Type serviceType,
    CallSiteChain callSiteChain,
  ) {
    if (_callSiteCache.containsKey(serviceType)) {
      var site = _callSiteCache[serviceType];
      if (site != null) {
        return site;
      } else {
        return createCallSite(serviceType, callSiteChain);
      }
    } else {
      return createCallSite(serviceType, callSiteChain);
    }
  }

  ServiceCallSite? getCallSite(
    ServiceDescriptor serviceDescriptor,
    CallSiteChain callSiteChain,
  ) {
    if (_descriptorLookup.containsKey(serviceDescriptor.serviceType)) {
      var descriptor = _descriptorLookup[serviceDescriptor.serviceType];
      return tryCreateExact(
        serviceDescriptor,
        serviceDescriptor.serviceType,
        callSiteChain,
        descriptor!.getSlot(serviceDescriptor),
      );
    }
    // ignore: lines_longer_than_80_chars
    // Debug.Fail("_descriptorLookup didn't contain requested serviceDescriptor");
    return null;
  }

  ServiceCallSite? createCallSite(
    Type serviceType,
    CallSiteChain callSiteChain,
  ) {
    callSiteChain.checkCircularDependency(serviceType);

    var callSite = _tryCreateExact(serviceType, callSiteChain) ??
        tryCreateIterable(serviceType, callSiteChain);

    // if (_descriptorLookup.containsKey(serviceType)) {
    //   var descriptor = _descriptorLookup[serviceType];
    //   callSite = tryCreateExact(
    //         descriptor!.last,
    //         serviceType,
    //         callSiteChain,
    //         defaultslot,
    //       ) ??
    //       tryCreateIterable(serviceType, callSiteChain);
    //   _callSiteCache[serviceType] = callSite!;
    // }
    return callSite;
  }

  ServiceCallSite? _tryCreateExact(
    Type serviceType,
    CallSiteChain callSiteChain,
  ) {
    if (_descriptorLookup.keys
            .where((e) => e.runtimeType == serviceType)
            .length >
        1) {
      return null;
    }

    if (_descriptorLookup.containsKey(serviceType)) {
      var descriptor = _descriptorLookup[serviceType];
      return tryCreateExact(
        descriptor!.last,
        serviceType,
        callSiteChain,
        defaultslot,
      );
    }
    return null;
  }

  ServiceCallSite? tryCreateIterable(
    Type serviceType,
    CallSiteChain callSiteChain,
  ) {
    Type? itemType;

    try {
      callSiteChain.add(serviceType);

      var name = serviceType.toString();
      var reg = RegExp(r'\<([^)]+)\>');

      String? x;
      if (name.contains('Iterable')) {
        var t = reg.stringMatch(name);
        x = t?.substring(1, t.length - 1);
        // TODO: Remove this.
        //print(x);
      }

      var cacheLocation = CallSiteResultCacheLocation.root;
      var callSites = <ServiceCallSite>[];
      // var descriptors = _descriptors
      //     .where((element) => element.serviceType.toString() == x)
      //     .toList();

      var descriptors = _descriptors
          .where((e) => e.implementationType.hashCode == serviceType.hashCode)
          .toList();

      if (descriptors.isNotEmpty) {
        itemType = descriptors.first.serviceType;
      }

      for (var i = 0; i < descriptors.length; i++) {
        var descriptor = descriptors[i];
        // Last service should get slot 0
        var slot = descriptors.length - i - 1;
        // var callSite =
        //     tryCreateExact(descriptor, itemType!, callSiteChain, slot);
        var callSite = tryCreateExact(
            descriptor, descriptors[i].serviceType, callSiteChain, slot);
        assert(callSite != null);
        //cacheLocation =
        //    getCommonCacheLocation(cacheLocation, callSite.cache.location);
        callSites.add(callSite!);
      }

      var resultCache = ResultCache.none;
      if ((cacheLocation == CallSiteResultCacheLocation.scope) ||
          (cacheLocation == CallSiteResultCacheLocation.root)) {
        resultCache =
            ResultCache(cacheLocation, ServiceCacheKey(itemType, defaultslot));
      }

      return IterableCallSite(resultCache, itemType ?? Object, callSites);
    } finally {
      callSiteChain.remove(serviceType);
    }
  }

  ServiceCallSite? tryCreateExact(
    ServiceDescriptor descriptor,
    Type serviceType,
    CallSiteChain callSiteChain,
    int slot,
  ) {
    if (serviceType == descriptor.serviceType) {
      ServiceCallSite callSite;
      var lifetime = ResultCache.fromServiceLifetime(
        descriptor.lifetime,
        serviceType,
        slot,
      );
      if (descriptor.implementationInstance != null) {
        callSite = ConstantCallSite(
          descriptor.serviceType,
          descriptor.implementationInstance,
        );
      } else if (descriptor.implementationFactory != null) {
        callSite = FactoryCallSite(
          lifetime,
          descriptor.serviceType,
          descriptor.implementationFactory!,
        );
      } else {
        throw Exception('SR.InvalidServiceDescriptor');
      }

      return callSite;
    }
    return null;
  }

  @override
  bool isService({required Type serviceType}) {
    if (_descriptorLookup.containsKey(serviceType)) {
      return true;
    }

    // These are the built in service types that aren't part of the list of
    // service descriptors. If you update these make sure to also update the
    // code in ServiceProvider.ctor
    return serviceType is ServiceProvider ||
        serviceType is ServiceProviderFactory ||
        serviceType is ServiceProviderIsService;
  }
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
        return index + 1;
      }
    }

    throw Exception('SR.ServiceDescriptorNotExist');
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

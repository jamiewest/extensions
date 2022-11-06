import 'dart:math';

import 'package:characters/characters.dart';

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
import 'service_cache_key.dart';
import 'service_call_site.dart';

class CallSiteFactory implements ServiceProviderIsService {
  final int defaultslot = 0;
  final Iterable<ServiceDescriptor> _descriptors;
  final Map<ServiceCacheKey, ServiceCallSite> _callSiteCache =
      <ServiceCacheKey, ServiceCallSite>{};
  final Map<Type, ServiceDescriptorCacheItem> _descriptorLookup =
      <Type, ServiceDescriptorCacheItem>{};

  CallSiteFactory(Iterable<ServiceDescriptor> descriptors)
      : _descriptors = descriptors {
    populate();
  }

  void populate() {
    for (var descriptor in _descriptors) {
      var serviceType = descriptor.serviceType;
      var cacheKey = serviceType;
      ServiceDescriptorCacheItem cacheItem;
      if (_descriptorLookup.containsKey(cacheKey)) {
        cacheItem = _descriptorLookup[cacheKey]!;
      } else {
        cacheItem = ServiceDescriptorCacheItem();
      }

      _descriptorLookup[cacheKey] = cacheItem.add(descriptor);
    }
  }

  void add(Type type, ServiceCallSite serviceCallSite) {
    _callSiteCache[ServiceCacheKey(type, defaultslot)] = serviceCallSite;
  }

  ServiceCallSite? getCallSiteFromType(
    Type serviceType,
    CallSiteChain callSiteChain,
  ) {
    if (_callSiteCache.containsKey(ServiceCacheKey(serviceType, defaultslot))) {
      var site = _callSiteCache[ServiceCacheKey(serviceType, defaultslot)];
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

    return null;
  }

  ServiceCallSite? createCallSite(
    Type serviceType,
    CallSiteChain callSiteChain,
  ) {
    callSiteChain.checkCircularDependency(serviceType);

    final callSite = _tryCreateExact(serviceType, callSiteChain) ??
        tryCreateIterable(serviceType, callSiteChain);

    return callSite;
  }

  ServiceCallSite? _tryCreateExact(
    Type serviceType,
    CallSiteChain callSiteChain,
  ) {
    if (_descriptorLookup.containsKey(serviceType)) {
      var descriptor = _descriptorLookup[serviceType]!;

      return tryCreateExact(
        descriptor.last,
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
    var callSiteKey = ServiceCacheKey(serviceType, defaultslot);
    if (_callSiteCache.containsKey(callSiteKey)) {
      return _callSiteCache[callSiteKey];
    }

    try {
      callSiteChain.add(serviceType);

      if (serviceType.toString().contains('Iterable')) {
        Type? itemType;
        var cacheLocation = CallSiteResultCacheLocation.root;
        var callSites = <ServiceCallSite>[];

        var typeName = serviceType.toString().replaceFirst('Iterable', '');
        if (typeName.characters.first == '<') {
          typeName = typeName.substring(1, typeName.length);
        }

        if (typeName.characters.last == '>') {
          typeName = typeName.substring(0, typeName.length - 1);
        }

        // final regex = RegExp(r'\<([^>]+)\>');
        // final match = regex.firstMatch(serviceType.toString());

        // if (match != null) {
        //   final result = match[0];
        //   if (result != null) {
        //     int idx;

        //     if (idx > 2) {
        //       name = result.substring(1, result.length);
        //     } else {
        //       name = result.substring(1, result.length - 1);
        //     }

        for (var descriptor in _descriptors) {
          if (descriptor.serviceType.toString() == typeName) {
            itemType = descriptor.serviceType;
            break;
          }
        }

        // } else {
        //   // We didn't find a regex result.
        //   return null;
        // }

        if (_descriptorLookup.containsKey(itemType)) {
          var descriptors = _descriptorLookup[itemType];
          for (var i = 0; i < descriptors!.length; i++) {
            var descriptor = descriptors[i];

            // Last service should get slot 0
            var slot = descriptors.length - i - 1;
            var callSite = tryCreateExact(
              descriptor,
              itemType!,
              callSiteChain,
              slot,
            );
            assert(callSite != null);
            cacheLocation = _getCommonCacheLocation(
              cacheLocation,
              callSite!.cache.location,
            );
            callSites.add(callSite);
          }
        }

        var resultCache = ResultCache.none;
        if ((cacheLocation == CallSiteResultCacheLocation.scope) ||
            (cacheLocation == CallSiteResultCacheLocation.root)) {
          resultCache = ResultCache(
            cacheLocation,
            ServiceCacheKey(itemType, defaultslot),
          );
        }

        return _callSiteCache[callSiteKey] = IterableCallSite(
          resultCache,
          serviceType,
          itemType,
          callSites,
        );
      } else {
        return null;
      }

      // var cacheLocation = CallSiteResultCacheLocation.root;
      // var callSites = <ServiceCallSite>[];

      // if (_descriptorLookup.containsKey(itemType)) {
      //   var descriptors = _descriptorLookup[itemType];
      //   for (var i = 0; i < descriptors!.length; i++) {
      //     var descriptor = descriptors[i];

      //     // Last service should get slot 0
      //     var slot = descriptors.length - i - 1;
      //     var callSite = tryCreateExact(
      //       descriptor,
      //       itemType,
      //       callSiteChain,
      //       slot,
      //     );
      //     assert(callSite != null);
      //     cacheLocation = _getCommonCacheLocation(
      //       cacheLocation,
      //       callSite!.cache.location,
      //     );
      //     callSites.add(callSite);
      //   }
      // }

    } finally {
      callSiteChain.remove(serviceType);
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
    Type serviceType,
    CallSiteChain callSiteChain,
    int slot,
  ) {
    if (serviceType == descriptor.serviceType) {
      var callSiteKey = ServiceCacheKey(serviceType, slot);
      if (_callSiteCache.containsKey(callSiteKey)) {
        return _callSiteCache[callSiteKey];
      }

      ServiceCallSite callSite;
      var lifetime = ResultCache.builder(
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
        throw Exception('Invalid service descriptor');
      }
      _callSiteCache[callSiteKey] = callSite;
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

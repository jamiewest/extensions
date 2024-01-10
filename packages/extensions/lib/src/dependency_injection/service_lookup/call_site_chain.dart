import 'dart:collection';

import 'package:extensions/src/dependency_injection/service_lookup/service_identifier.dart';

class CallSiteChain {
  final Map<ServiceIdentifier, ChainItemInfo> _callSiteChain;

  CallSiteChain() : _callSiteChain = <ServiceIdentifier, ChainItemInfo>{};

  void checkCircularDependency(ServiceIdentifier serviceIdentifier) {
    if (_callSiteChain.containsKey(ServiceIdentifier)) {
      throw Exception(
          _createCircularDependencyExceptionMessage(serviceIdentifier));
    }
  }

  void remove(ServiceIdentifier serviceIdentifier) =>
      _callSiteChain.remove(serviceIdentifier);

  void add(ServiceIdentifier serviceIdentifier, [Type? implementationType]) {
    _callSiteChain[serviceIdentifier] = ChainItemInfo(
      _callSiteChain.length,
      implementationType,
    );
  }

  String _createCircularDependencyExceptionMessage(
    ServiceIdentifier serviceIdentifier,
  ) {
    var messageBuilder = StringBuffer()
      ..write('''
        A circular dependency was detected for the service of 
        type '${serviceIdentifier.serviceType.runtimeType.toString()}'.''')
      ..writeln();

    _appendResolutionPath(messageBuilder, serviceIdentifier);

    return messageBuilder.toString();
  }

  void _appendResolutionPath(
      StringBuffer builder, ServiceIdentifier currentlyResolving) {
    final ordered = SplayTreeMap<Type, ChainItemInfo>.from(
      _callSiteChain,
      (key1, key2) =>
          _callSiteChain[key1]!.order.compareTo(_callSiteChain[key2]!.order),
    );

    for (var pair in ordered.entries) {
      var serviceType = pair.key;
      var implementationType = pair.value.implementationType;
      if (implementationType == null || serviceType == implementationType) {
        builder.write(serviceType.runtimeType.toString());
      } else {
        builder.write('''${serviceType.runtimeType.toString()}
            (${implementationType.runtimeType.toString()})''');
      }

      builder.write(' -> ');
    }

    builder.write(currentlyResolving.serviceType.runtimeType.toString());
  }
}

class ChainItemInfo {
  const ChainItemInfo(
    this.order,
    this.implementationType,
  );

  final int order;
  final Type? implementationType;
}

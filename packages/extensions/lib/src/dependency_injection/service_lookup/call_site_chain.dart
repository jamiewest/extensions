import 'dart:collection';

import '../../system/exceptions/invalid_operation_exception.dart';
import 'service_identifier.dart';

class CallSiteChain {
  final Map<ServiceIdentifier, ChainItemInfo> _callSiteChain;

  CallSiteChain() : _callSiteChain = <ServiceIdentifier, ChainItemInfo>{};

  void checkCircularDependency(ServiceIdentifier serviceIdentifier) {
    if (_callSiteChain.containsKey(serviceIdentifier)) {
      throw InvalidOperationException(
        message: _createCircularDependencyExceptionMessage(serviceIdentifier),
      );
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
      ..write(
        'A circular dependency was detected for the service of '
        "type '${serviceIdentifier.toString()}'.",
      )
      ..writeln();

    _appendResolutionPath(messageBuilder, serviceIdentifier);

    return messageBuilder.toString();
  }

  void _appendResolutionPath(
    StringBuffer builder,
    ServiceIdentifier currentlyResolving,
  ) {
    final ordered = SplayTreeMap<ServiceIdentifier, ChainItemInfo>.from(
      _callSiteChain,
      (key1, key2) =>
          _callSiteChain[key1]!.order.compareTo(_callSiteChain[key2]!.order),
    );

    for (var pair in ordered.entries) {
      var serviceId = pair.key;
      var implementationType = pair.value.implementationType;
      if (implementationType == null ||
          serviceId.serviceType == implementationType) {
        builder.write(serviceId.toString());
      } else {
        builder.write(
          '''${serviceId.toString()}
            (${implementationType.toString()})''',
        );
      }

      builder.write(' -> ');
    }

    builder.write(currentlyResolving.serviceType.toString());
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

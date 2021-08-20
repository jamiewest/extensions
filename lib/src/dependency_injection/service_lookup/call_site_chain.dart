class CallSiteChain {
  final Map<Type, ChainItemInfo> _callSiteChain;

  CallSiteChain() : _callSiteChain = <Type, ChainItemInfo>{};

  void checkCircularDependency(Type serviceType) {
    if (_callSiteChain.containsKey(serviceType)) {
      throw Exception(_createCircularDependencyExceptionMessage(serviceType));
    }
  }

  void remove(Type serviceType) => _callSiteChain.remove(serviceType);

  void add(Type serviceType, [Type? implementationType]) {
    _callSiteChain[serviceType] = ChainItemInfo(
      _callSiteChain.length,
      implementationType,
    );
  }

  String _createCircularDependencyExceptionMessage(Type type) {
    var messageBuilder = StringBuffer()
      ..write('''
        A circular dependency was detected for the service of 
        type '${type.runtimeType.toString()}'.''')
      ..writeln();

    _appendResolutionPath(messageBuilder, type);

    return messageBuilder.toString();
  }

  void _appendResolutionPath(StringBuffer builder, [Type? currentlyResolving]) {
    for (var pair in _callSiteChain.entries) {
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

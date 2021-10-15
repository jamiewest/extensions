class ServiceCacheKey {
  final Type? _type;
  final int _slot;

  ServiceCacheKey(Type? type, int slot)
      : _type = type,
        _slot = slot;

  static ServiceCacheKey get empty => ServiceCacheKey(null, 0);

  /// Type of service being cached
  Type? get type => _type;

  /// Reverse index of the service when resolved in an `Iterable`
  /// where default instance gets slot 0.
  /// For example for service collection
  ///  IService Impl1
  ///  IService Impl2
  ///  IService Impl3
  /// We would get the following cache keys:
  ///  Impl1 2
  ///  Impl2 1
  ///  Impl3 0
  int get slot => _slot;

  @override
  bool operator ==(Object other) =>
      other is ServiceCacheKey && _type == other.type && _slot == other.slot;

  @override
  int get hashCode => (type.hashCode * 397) ^ _slot;
}

import 'dart:collection';

import 'service_descriptor.dart';

/// Specifies the contract for a collection of service descriptors.
class ServiceCollection with ListMixin<ServiceDescriptor> {
  final List<ServiceDescriptor> _descriptors = <ServiceDescriptor>[];
  bool _isReadOnly = false;

  @override
  ServiceDescriptor operator [](int index) => _descriptors[index];

  @override
  void operator []=(int index, ServiceDescriptor value) {
    checkReadOnly();
    _descriptors[index] = value;
  }

  @override
  int get length => _descriptors.length;

  @override
  set length(int value) => _descriptors.length = value;

  @override
  void add(ServiceDescriptor element) {
    checkReadOnly();
    _descriptors.insert(length, element);
  }

  /// Makes this collection read-only.
  void makeReadOnly() {
    _isReadOnly = true;
  }

  void checkReadOnly() {
    if (_isReadOnly) {
      throw Exception('ServiceCollection is read-only.');
    }
  }
}

import 'dart:collection';

import '../common/exceptions/invalid_operation_exception.dart';

import 'service_descriptor.dart';

const String _serviceCollectionReadOnly =
    'The service collection cannot be modified because it is read-only.';

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
      _throwReadOnlyException();
    }
  }

  static void _throwReadOnlyException() {
    /// TODO: FIX THIS
    //throw InvalidOperationException(message: _serviceCollectionReadOnly);
  }
}

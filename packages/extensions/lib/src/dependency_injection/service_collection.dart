import 'dart:collection';

import '../system/exceptions/invalid_operation_exception.dart';

import 'service_descriptor.dart';

const String _serviceCollectionReadOnly =
    'The service collection cannot be modified because it is read-only.';

/// Specifies the contract for a collection of service descriptors.
///
/// Adapted from [ServiceCollection.cs](https://github.com/dotnet/runtime/blob/main/src/libraries/Microsoft.Extensions.DependencyInjection.Abstractions/src/ServiceCollection.cs)
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

  bool get isReadOnly => _isReadOnly;

  @override
  int get length => _descriptors.length;

  @override
  set length(int value) {
    checkReadOnly();
    _descriptors.length = value;
  }

  @override
  void add(ServiceDescriptor element) {
    checkReadOnly();
    _descriptors.insert(length, element);
  }

  @override
  void clear() {
    checkReadOnly();
    super.clear();
  }

  @override
  bool remove(Object? element) {
    checkReadOnly();
    return super.remove(element);
  }

  @override
  ServiceDescriptor removeAt(int index) {
    checkReadOnly();
    return super.removeAt(index);
  }

  @override
  void insert(int index, ServiceDescriptor element) {
    checkReadOnly();
    super.insert(index, element);
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
    throw InvalidOperationException(message: _serviceCollectionReadOnly);
  }
}

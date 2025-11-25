import '../../system/exceptions/argument_null_exception.dart';
import 'diagnostics.dart';

/// Options for creating a [Meter].
class MeterOptions {
  String _name;

  MeterOptions(String name) : _name = name;

  String get name => _name;

  set name(String? name) {
    if (name != null) {
      _name = name;
    } else {
      throw ArgumentNullException(paramName: 'value');
    }
  }

  /// The optional Meter version.
  String? version;

  /// The optional list of key-value pair tags associated with the meter.
  Map<String, Object?>? tags;

  /// The optional opaque object to attach to the Meter. The scope object can
  /// be attached to multiple meters for scoping purposes.
  Object? scope;
}

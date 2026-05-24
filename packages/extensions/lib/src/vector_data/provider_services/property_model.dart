import 'package:extensions/annotations.dart';

/// Represents a property on a vector store record.
///
/// This is a support type for provider implementors; application code should
/// not reference it directly.
@Source(
  name: 'PropertyModel.cs',
  namespace: 'Microsoft.Extensions.VectorData.ProviderServices',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/'
      'ProviderServices/',
)
abstract class PropertyModel {
  /// Creates a [PropertyModel] with the given [modelName] and [type].
  PropertyModel({
    required this.modelName,
    required this.type,
    this.isNullable = true,
  });

  Object? Function(Object record)? _getter;
  void Function(Object record, Object? value)? _setter;
  String? _storageName;

  /// The model name of the property.
  ///
  /// When the property corresponds to a record field, this is that field's
  /// name.
  String modelName;

  /// The storage name used in the vector store.
  ///
  /// Defaults to [modelName] when not set.
  String get storageName => _storageName ?? modelName;
  set storageName(String value) => _storageName = value;

  /// The Dart [Type] of the property.
  Type type;

  /// Whether the property accepts null values.
  ///
  /// Because Dart's nullability is encoded in the static type system,
  /// this must be supplied explicitly when constructing the model.
  final bool isNullable;

  /// Provider-specific annotations for this property.
  Map<String, Object?>? providerAnnotations;

  /// Configures explicit getter and setter callbacks for POCO mapping.
  void configureAccessors(
    Object? Function(Object record) getter,
    void Function(Object record, Object? value) setter,
  ) {
    _getter = getter;
    _setter = setter;
  }

  /// Configures getter and setter callbacks for dynamic
  /// `Map<String, Object?>` mapping.
  void configureDynamicAccessors() {
    _getter = (record) {
      final map = record as Map<String, Object?>;
      return map[modelName];
    };
    _setter = (record, value) {
      (record as Map<String, Object?>)[modelName] = value;
    };
  }

  /// Reads the property value from [record] as an [Object?].
  Object? getValueAsObject(Object record) {
    assert(_getter != null, 'Property accessors have not been configured.');
    return _getter!(record);
  }

  /// Writes [value] to the property on [record].
  void setValueAsObject(Object record, Object? value) {
    assert(_setter != null, 'Property accessors have not been configured.');
    _setter!(record, value);
  }

  /// Reads the property value from [record] as [T].
  T getValue<T>(Object record) => getValueAsObject(record) as T;

  /// Writes a typed [value] to the property on [record].
  void setValue<T>(Object record, T value) =>
      setValueAsObject(record, value);
}

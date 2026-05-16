import 'package:extensions/annotations.dart';

/// Base class for all vector store record property definitions.
@Source(
  name: 'VectorStoreProperty.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/RecordDefinition/',
)
abstract class VectorStoreProperty {
  /// Creates a new [VectorStoreProperty] with the given [propertyName].
  ///
  /// [propertyName] is the name of the property on the record model.
  VectorStoreProperty(this.propertyName);

  /// The name of the property on the record model.
  final String propertyName;

  /// The name used when storing this property in the vector store.
  ///
  /// Defaults to [propertyName] when null.
  String? storageName;
}

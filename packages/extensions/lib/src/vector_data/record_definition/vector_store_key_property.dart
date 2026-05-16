import 'package:extensions/annotations.dart';

import 'vector_store_property.dart';

/// Defines a key property in a vector store record.
///
/// Exactly one [VectorStoreKeyProperty] must appear in a
/// [VectorStoreCollectionDefinition].
@Source(
  name: 'VectorStoreKeyProperty.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/RecordDefinition/',
)
final class VectorStoreKeyProperty extends VectorStoreProperty {
  /// Creates a [VectorStoreKeyProperty] for [propertyName].
  VectorStoreKeyProperty(super.propertyName);
}

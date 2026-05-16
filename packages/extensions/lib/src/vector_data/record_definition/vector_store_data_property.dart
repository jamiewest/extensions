import 'package:extensions/annotations.dart';

import 'vector_store_property.dart';

/// Defines a data property in a vector store record.
///
/// Data properties store the non-vector payload fields of a record.
@Source(
  name: 'VectorStoreDataProperty.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/RecordDefinition/',
)
final class VectorStoreDataProperty extends VectorStoreProperty {
  /// Creates a [VectorStoreDataProperty] for [propertyName].
  VectorStoreDataProperty(super.propertyName);

  /// Whether the property should be indexed for filtering.
  bool isIndexed = false;

  /// Whether the property should be indexed for full-text search.
  bool isFullTextIndexed = false;
}

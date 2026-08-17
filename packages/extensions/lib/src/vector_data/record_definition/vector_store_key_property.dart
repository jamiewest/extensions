import 'vector_store_property.dart';

/// Defines a key property in a vector store record.
///
/// Exactly one [VectorStoreKeyProperty] must appear in a
/// [VectorStoreCollectionDefinition].
final class VectorStoreKeyProperty extends VectorStoreProperty {
  /// Creates a [VectorStoreKeyProperty] for [propertyName].
  VectorStoreKeyProperty(super.propertyName);
}

/// Metadata about a vector store collection.
class VectorStoreCollectionMetadata {
  /// Creates a [VectorStoreCollectionMetadata].
  const VectorStoreCollectionMetadata({
    this.vectorStoreSystemName,
    this.vectorStoreName,
    this.collectionName,
  });

  /// The system name of the vector store (e.g., `'Redis'`, `'Qdrant'`).
  final String? vectorStoreSystemName;

  /// The name of the vector store instance.
  final String? vectorStoreName;

  /// The name of the collection.
  final String? collectionName;
}

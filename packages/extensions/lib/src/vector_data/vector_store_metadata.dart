/// Metadata about a vector store instance.
class VectorStoreMetadata {
  /// Creates a [VectorStoreMetadata].
  const VectorStoreMetadata({this.vectorStoreSystemName, this.vectorStoreName});

  /// The system name of the vector store (e.g., `'Redis'`, `'Qdrant'`).
  final String? vectorStoreSystemName;

  /// The name of the vector store instance.
  final String? vectorStoreName;
}

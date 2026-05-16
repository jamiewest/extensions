import 'package:extensions/annotations.dart';

/// Metadata about a vector store instance.
@Source(
  name: 'VectorStoreMetadata.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/',
)
class VectorStoreMetadata {
  /// Creates a [VectorStoreMetadata].
  const VectorStoreMetadata({this.vectorStoreSystemName, this.vectorStoreName});

  /// The system name of the vector store (e.g., `'Redis'`, `'Qdrant'`).
  final String? vectorStoreSystemName;

  /// The name of the vector store instance.
  final String? vectorStoreName;
}

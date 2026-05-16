import 'package:extensions/annotations.dart';

/// Represents an error that occurred while interacting with a vector store.
@Source(
  name: 'VectorStoreException.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/',
)
class VectorStoreException implements Exception {
  /// Creates a [VectorStoreException].
  VectorStoreException([this.message]) : cause = null;

  /// Creates a [VectorStoreException] with a [message] and inner [cause].
  VectorStoreException.withCause(this.message, this.cause);

  /// The error message.
  final String? message;

  /// The underlying cause of this exception, if any.
  final Object? cause;

  /// The system name of the vector store (e.g., `'Redis'`, `'Qdrant'`).
  String? vectorStoreSystemName;

  /// The name of the vector store instance.
  String? vectorStoreName;

  /// The name of the collection that was being operated on.
  String? collectionName;

  /// The name of the operation that was being performed.
  String? operationName;

  @override
  String toString() {
    final parts = <String>[];
    if (vectorStoreSystemName != null) parts.add(vectorStoreSystemName!);
    if (vectorStoreName != null) parts.add(vectorStoreName!);
    if (collectionName != null) parts.add(collectionName!);
    if (operationName != null) parts.add(operationName!);
    final context = parts.isEmpty ? '' : ' [${parts.join('/')}]';
    return 'VectorStoreException$context: ${message ?? ''}';
  }
}

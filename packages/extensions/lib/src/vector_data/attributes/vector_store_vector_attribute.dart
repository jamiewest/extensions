import 'package:extensions/annotations.dart';

/// Marks a property on a record as a vector field in a vector store collection.
///
/// Example:
/// ```dart
/// class Hotel {
///   @VectorStoreVectorAttribute(
///     dimensions: 1536,
///     indexKind: IndexKind.hnsw,
///     distanceFunction: DistanceFunction.cosineSimilarity,
///   )
///   final List<double>? descriptionEmbedding;
///
///   Hotel({this.descriptionEmbedding});
/// }
/// ```
///
/// Since Dart has no built-in runtime reflection, annotations are intended for
/// use with code generators or explicit [VectorStoreCollectionDefinition]
/// construction.
@Source(
  name: 'VectorStoreVectorAttribute.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/Attributes/',
)
final class VectorStoreVectorAttribute {
  /// Creates a [VectorStoreVectorAttribute].
  ///
  /// [dimensions] is required and specifies the number of dimensions in the
  /// vector.
  const VectorStoreVectorAttribute({
    required this.dimensions,
    this.storageName,
    this.indexKind,
    this.distanceFunction,
  });

  /// The number of dimensions in the vector.
  final int dimensions;

  /// The name used when storing this property in the vector store.
  final String? storageName;

  /// The index kind to use for this vector. See [IndexKind] for values.
  final String? indexKind;

  /// The distance function for this vector. See [DistanceFunction] for values.
  final String? distanceFunction;
}

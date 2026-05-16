import 'package:extensions/annotations.dart';

/// Marks a property on a record as a data field in a vector store collection.
///
/// Example:
/// ```dart
/// class Hotel {
///   @VectorStoreDataAttribute(isFullTextIndexed: true)
///   final String description;
///
///   Hotel({required this.description});
/// }
/// ```
///
/// Since Dart has no built-in runtime reflection, annotations are intended for
/// use with code generators or explicit [VectorStoreCollectionDefinition]
/// construction.
@Source(
  name: 'VectorStoreDataAttribute.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/Attributes/',
)
final class VectorStoreDataAttribute {
  /// Creates a [VectorStoreDataAttribute].
  const VectorStoreDataAttribute({
    this.storageName,
    this.isIndexed = false,
    this.isFullTextIndexed = false,
  });

  /// The name used when storing this property in the vector store.
  final String? storageName;

  /// Whether the property should be indexed for filtering.
  final bool isIndexed;

  /// Whether the property should be indexed for full-text search.
  final bool isFullTextIndexed;
}

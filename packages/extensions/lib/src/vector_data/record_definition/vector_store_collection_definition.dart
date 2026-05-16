import 'package:extensions/annotations.dart';

import 'vector_store_data_property.dart';
import 'vector_store_key_property.dart';
import 'vector_store_property.dart';
import 'vector_store_vector_property.dart';

/// Defines the schema of a vector store collection.
///
/// Provides the explicit property definitions used by a vector store when
/// reflection-based schema discovery is unavailable or undesirable. Pass an
/// instance to [VectorStoreCollectionOptions.definition] or to
/// [VectorStore.getCollection].
///
/// Example:
/// ```dart
/// final definition = VectorStoreCollectionDefinition(
///   properties: [
///     VectorStoreKeyProperty('id'),
///     VectorStoreDataProperty('content')..isFullTextIndexed = true,
///     VectorStoreVectorProperty('embedding', dimensions: 1536),
///   ],
/// );
/// ```
@Source(
  name: 'VectorStoreCollectionDefinition.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/RecordDefinition/',
)
final class VectorStoreCollectionDefinition {
  /// Creates a [VectorStoreCollectionDefinition] with the given [properties].
  VectorStoreCollectionDefinition({List<VectorStoreProperty>? properties})
      : properties = properties ?? [];

  /// The list of property definitions for this collection.
  ///
  /// Must contain exactly one [VectorStoreKeyProperty]. May contain any number
  /// of [VectorStoreDataProperty] and [VectorStoreVectorProperty] entries.
  final List<VectorStoreProperty> properties;

  /// Returns all [VectorStoreKeyProperty] entries.
  Iterable<VectorStoreKeyProperty> get keyProperties =>
      properties.whereType<VectorStoreKeyProperty>();

  /// Returns all [VectorStoreDataProperty] entries.
  Iterable<VectorStoreDataProperty> get dataProperties =>
      properties.whereType<VectorStoreDataProperty>();

  /// Returns all [VectorStoreVectorProperty] entries.
  Iterable<VectorStoreVectorProperty> get vectorProperties =>
      properties.whereType<VectorStoreVectorProperty>();
}

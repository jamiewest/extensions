import 'package:extensions/annotations.dart';

import '../ai/embeddings/embedding_generator.dart';
import 'record_definition/vector_store_collection_definition.dart';

/// Base options for configuring a [VectorStoreCollection].
///
/// Subclass this to add provider-specific options.
@Source(
  name: 'VectorStoreCollectionOptions.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/',
)
class VectorStoreCollectionOptions {
  /// Creates a [VectorStoreCollectionOptions].
  VectorStoreCollectionOptions({this.definition, this.embeddingGenerator});

  /// The explicit schema definition for the collection.
  ///
  /// When provided, the store uses this definition instead of deriving
  /// the schema from annotations or conventions.
  VectorStoreCollectionDefinition? definition;

  /// The embedding generator used to automatically produce vector embeddings.
  ///
  /// When set, the collection may call this generator to produce embeddings
  /// for properties whose [VectorStoreVectorProperty.embeddingType] is set.
  EmbeddingGenerator? embeddingGenerator;
}

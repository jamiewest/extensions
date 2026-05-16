import 'package:extensions/annotations.dart';

import 'vector_store_property.dart';

/// Defines a vector property in a vector store record.
///
/// Vector properties store the embedding data used for similarity search.
/// Use [embeddingType] to indicate the Dart type of the embedding model input
/// when auto-generation is configured (replaces the C# generic
/// `VectorStoreVectorProperty<TInput>`).
@Source(
  name: 'VectorStoreVectorProperty.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/RecordDefinition/',
)
class VectorStoreVectorProperty extends VectorStoreProperty {
  /// Creates a [VectorStoreVectorProperty] for [propertyName].
  ///
  /// [dimensions] is the number of dimensions in the vector. Some vector stores
  /// require this value when creating a collection.
  VectorStoreVectorProperty(super.propertyName, {this.dimensions});

  /// The number of dimensions in the vector.
  int? dimensions;

  /// The kind of index to use for this vector property.
  ///
  /// See [IndexKind] for supported values. Providers may support additional
  /// values or may ignore this when not applicable.
  String? indexKind;

  /// The distance function to use when comparing vectors.
  ///
  /// See [DistanceFunction] for supported values. Providers may support
  /// additional values or may ignore this when not applicable.
  String? distanceFunction;

  /// The Dart [Type] of the embedding model input for auto-generation.
  ///
  /// When set, the vector store will attempt to use a registered
  /// embedding generator that accepts this input type to automatically
  /// generate the embedding before upsert or search.
  Type? embeddingType;
}

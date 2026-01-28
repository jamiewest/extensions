import '../additional_properties_dictionary.dart';

/// Represents a generated embedding vector.
class Embedding {
  /// Creates a new [Embedding].
  Embedding({
    required this.vector,
    this.createdAt,
    this.modelId,
    this.additionalProperties,
  });

  /// The embedding vector.
  final List<double> vector;

  /// The number of dimensions in the vector.
  int get dimensions => vector.length;

  /// When the embedding was created.
  DateTime? createdAt;

  /// The model that generated this embedding.
  String? modelId;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;
}

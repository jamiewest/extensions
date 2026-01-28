import '../additional_properties_dictionary.dart';
import '../usage_details.dart';
import 'embedding.dart';

/// Represents a collection of generated embeddings.
class GeneratedEmbeddings {
  /// Creates a new [GeneratedEmbeddings].
  GeneratedEmbeddings([List<Embedding>? embeddings])
      : _embeddings = embeddings ?? [];

  final List<Embedding> _embeddings;

  /// Usage details for the embedding generation.
  UsageDetails? usage;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// The number of embeddings.
  int get length => _embeddings.length;

  /// Whether the collection is empty.
  bool get isEmpty => _embeddings.isEmpty;

  /// Access an embedding by index.
  Embedding operator [](int index) => _embeddings[index];

  /// Adds an embedding to the collection.
  void add(Embedding embedding) => _embeddings.add(embedding);

  /// Adds all embeddings from [embeddings].
  void addAll(Iterable<Embedding> embeddings) =>
      _embeddings.addAll(embeddings);

  /// Returns an iterator over the embeddings.
  Iterator<Embedding> get iterator => _embeddings.iterator;

  /// Returns the embeddings as a list.
  List<Embedding> toList() => List.unmodifiable(_embeddings);
}

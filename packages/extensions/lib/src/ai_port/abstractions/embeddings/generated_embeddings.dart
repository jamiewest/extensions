import '../usage_details.dart';

/// Represents the result of an operation to generate embeddings.
///
/// [TEmbedding] Specifies the type of the generated embeddings.
class GeneratedEmbeddings<TEmbedding> implements List<TEmbedding> {
  /// Initializes a new instance of the [GeneratedEmbeddings] class that
  /// contains all of the embeddings from the specified collection.
  ///
  /// [embeddings] The collection whose embeddings are copied to the new list.
  GeneratedEmbeddings({
    int? capacity = null,
    Iterable<TEmbedding>? embeddings = null,
  }) : _embeddings = List<TEmbedding>(Throw.ifNull(embeddings));

  /// The underlying list of embeddings.
  List<TEmbedding> _embeddings;

  /// Gets or sets usage details for the embeddings' generation.
  UsageDetails? usage;

  /// Gets or sets any additional properties associated with the embeddings.
  AdditionalPropertiesDictionary? additionalProperties;

  TEmbedding item;

  int get count {
    return _embeddings.count;
  }

  bool get isReadOnly {
    return false;
  }

  @override
  void add(TEmbedding item) {
    _embeddings.add(item);
  }

  /// Adds the embeddings from the specified collection to the end of this list.
  ///
  /// [items] The collection whose elements should be added to this list.
  void addRange(Iterable<TEmbedding> items) {
    _embeddings.addRange(items);
  }

  @override
  void clear() {
    _embeddings.clear();
  }

  @override
  bool contains(TEmbedding item) {
    return _embeddings.contains(item);
  }

  @override
  void copyTo(List<TEmbedding> array, int arrayIndex) {
    _embeddings.copyTo(array, arrayIndex);
  }

  @override
  Iterable<TEmbedding> getIterable() {
    return _embeddings.getIterable();
  }

  Iterable getIterable() {
    return getIterable();
  }

  @override
  int indexOf(TEmbedding item) {
    return _embeddings.indexOf(item);
  }

  @override
  void insert(int index, TEmbedding item) {
    _embeddings.insert(index, item);
  }

  @override
  bool remove(TEmbedding item) {
    return _embeddings.remove(item);
  }

  @override
  void removeAt(int index) {
    _embeddings.removeAt(index);
  }
}

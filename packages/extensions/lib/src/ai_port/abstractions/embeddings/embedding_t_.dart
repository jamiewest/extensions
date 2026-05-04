/// Represents an embedding composed of a vector of `T` values.
///
/// Remarks: Typical values of `T` are [Single], [Double], or Half.
///
/// [T] The type of the values in the embedding vector.
class Embedding<T> extends Embedding {
  /// Initializes a new instance of the [Embedding] class with the embedding
  /// vector.
  ///
  /// [vector] The embedding vector this embedding represents.
  const Embedding(ReadOnlyMemory<T> vector) : vector = vector;

  /// Gets or sets the embedding vector this embedding represents.
  ReadOnlyMemory<T> vector;

  int get dimensions {
    return vector.length;
  }
}

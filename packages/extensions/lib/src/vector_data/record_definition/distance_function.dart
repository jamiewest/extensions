import 'package:extensions/annotations.dart';

/// Defines the distance functions that can be used to measure similarity
/// between vectors in a vector store.
@Source(
  name: 'DistanceFunction.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/RecordDefinition/',
)
abstract final class DistanceFunction {
  /// Measures the cosine of the angle between two vectors.
  ///
  /// Values range from -1 to 1, where 1 means identical direction.
  /// Higher values indicate greater similarity.
  static const String cosineSimilarity = 'CosineSimilarity';

  /// Measures the cosine distance between two vectors (1 - CosineSimilarity).
  ///
  /// Values range from 0 to 2, where 0 means identical direction.
  /// Lower values indicate greater similarity.
  static const String cosineDistance = 'CosineDistance';

  /// Measures the dot product of two vectors.
  ///
  /// Higher values indicate greater similarity. Requires normalized vectors
  /// to be equivalent to cosine similarity.
  static const String dotProductSimilarity = 'DotProductSimilarity';

  /// Measures the negative dot product of two vectors.
  ///
  /// Lower values indicate greater similarity.
  static const String negativeDotProductSimilarity =
      'NegativeDotProductSimilarity';

  /// Measures the straight-line Euclidean distance between two vectors.
  ///
  /// Lower values indicate greater similarity.
  static const String euclideanDistance = 'EuclideanDistance';

  /// Measures the squared Euclidean distance between two vectors.
  ///
  /// Avoids the square-root computation for faster comparisons.
  /// Lower values indicate greater similarity.
  static const String euclideanSquaredDistance = 'EuclideanSquaredDistance';

  /// Measures the Hamming distance between two binary vectors.
  ///
  /// Counts the number of positions where the values differ.
  /// Lower values indicate greater similarity.
  static const String hammingDistance = 'HammingDistance';

  /// Measures the Manhattan (L1) distance between two vectors.
  ///
  /// Sums the absolute differences of their coordinates.
  /// Lower values indicate greater similarity.
  static const String manhattanDistance = 'ManhattanDistance';
}

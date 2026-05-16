import 'package:extensions/annotations.dart';

/// Represents a single result from a vector similarity search.
///
/// Contains the matched record and, when provided by the store, a similarity
/// score.
@Source(
  name: 'VectorSearchResult.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/',
)
final class VectorSearchResult<TRecord> {
  /// Creates a [VectorSearchResult] for [record].
  const VectorSearchResult(this.record, {this.score});

  /// The matched record.
  final TRecord record;

  /// The similarity score assigned by the vector store.
  ///
  /// The interpretation of this value depends on the [DistanceFunction] used
  /// by the vector property. May be null if the store does not return scores.
  final double? score;
}

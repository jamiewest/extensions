import 'package:extensions/annotations.dart';

/// Defines the types of index that can be used to index vector data.
@Source(
  name: 'IndexKind.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/RecordDefinition/',
)
abstract final class IndexKind {
  /// Hierarchical Navigable Small World (HNSW) graph-based index.
  ///
  /// HNSW offers a good balance of recall and search performance with
  /// relatively high memory usage.
  static const String hnsw = 'Hnsw';

  /// Flat index, also known as exhaustive k-nearest-neighbors (KNN).
  ///
  /// Flat index performs a brute-force search across all vectors, which
  /// guarantees perfect recall at the cost of high search performance.
  static const String flat = 'Flat';

  /// IVF flat index (Inverted File Flat).
  ///
  /// This index type is supported by some vector stores.
  static const String ivfFlat = 'IvfFlat';

  /// DiskANN index, an approximate nearest-neighbor search algorithm
  /// designed for large datasets stored on disk.
  static const String diskAnn = 'DiskAnn';

  /// Quantized flat index using scalar or product quantization to reduce
  /// memory usage at some recall cost.
  static const String quantizedFlat = 'QuantizedFlat';

  /// Dynamic index that automatically selects between [flat] and [hnsw]
  /// based on collection size.
  static const String dynamic = 'Dynamic';
}

import 'package:extensions/annotations.dart';

/// Options for retrieving records from a vector store collection by key.
@Source(
  name: 'RecordRetrievalOptions.cs',
  namespace: 'Microsoft.Extensions.VectorData',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/VectorData/',
)
class RecordRetrievalOptions {
  /// Creates a [RecordRetrievalOptions].
  RecordRetrievalOptions({this.includeVectors = false});

  /// Whether to include vector fields in the retrieved records.
  ///
  /// Defaults to `false`. Set to `true` if the application needs to inspect
  /// the raw embedding data.
  bool includeVectors;
}

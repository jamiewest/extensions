import 'package:extensions/annotations.dart';

import 'property_model.dart';

/// Represents a data property on a vector store record.
///
/// This is a support type for provider implementors; application code should
/// not reference it directly.
@Source(
  name: 'DataPropertyModel.cs',
  namespace: 'Microsoft.Extensions.VectorData.ProviderServices',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/'
      'ProviderServices/',
)
class DataPropertyModel extends PropertyModel {
  /// Creates a [DataPropertyModel] with the given [modelName] and [type].
  DataPropertyModel({
    required super.modelName,
    required super.type,
    super.isNullable,
  });

  /// Whether this property should be indexed for filtering.
  bool isIndexed = false;

  /// Whether this property should be indexed for full-text search.
  bool isFullTextIndexed = false;

  @override
  String toString() => '$modelName (Data, $type)';
}

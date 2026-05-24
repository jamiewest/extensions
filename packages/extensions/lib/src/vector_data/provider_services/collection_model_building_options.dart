import 'package:extensions/annotations.dart';

/// Options that control how a [CollectionModel] is built.
///
/// This is a support type for provider implementors; application code should
/// not reference it directly.
@Source(
  name: 'CollectionModelBuildingOptions.cs',
  namespace: 'Microsoft.Extensions.VectorData.ProviderServices',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/'
      'ProviderServices/',
)
final class CollectionModelBuildingOptions {
  /// Creates a [CollectionModelBuildingOptions].
  const CollectionModelBuildingOptions({
    required this.supportsMultipleVectors,
    required this.requiresAtLeastOneVector,
    this.usesExternalSerializer = false,
    this.reservedKeyStorageName,
  });

  /// Whether the provider supports multiple vector properties per record.
  final bool supportsMultipleVectors;

  /// Whether the provider requires at least one vector property.
  final bool requiresAtLeastOneVector;

  /// Whether the provider uses an external serializer (e.g. `dart:convert`)
  /// to transform records instead of the model's property accessors.
  final bool usesExternalSerializer;

  /// A reserved storage name for the key property that the provider always
  /// uses, regardless of the model name.
  ///
  /// When set, the builder enforces this name and prevents customisation.
  final String? reservedKeyStorageName;
}

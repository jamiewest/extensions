import 'package:extensions/annotations.dart';

import 'vector_property_model.dart';

/// Error message factory for vector store provider implementations.
///
/// This is a support type for provider implementors; application code should
/// not reference it directly.
@Source(
  name: 'VectorDataStrings.cs',
  namespace: 'Microsoft.Extensions.VectorData.ProviderServices',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/'
      'ProviderServices/',
)
abstract final class VectorDataStrings {
  /// Error for when the configured embedding type is not supported by the
  /// generator.
  static String configuredEmbeddingTypeIsUnsupportedByTheGenerator(
    VectorPropertyModel vectorProperty,
    Type userRequestedEmbeddingType,
  ) =>
      "Vector property '${vectorProperty.modelName}' has embedding type "
      "'${_typeName(userRequestedEmbeddingType)}' configured, but that type "
      "isn't supported by your embedding generator.";

  /// Error for when the configured embedding type is not supported by the
  /// provider.
  static String configuredEmbeddingTypeIsUnsupportedByTheProvider(
    VectorPropertyModel vectorProperty,
    Type userRequestedEmbeddingType,
    String supportedVectorTypes,
  ) =>
      "Vector property '${vectorProperty.modelName}' has embedding type "
      "'${_typeName(userRequestedEmbeddingType)}' configured, but that type "
      "isn't supported by your provider. Supported types are "
      '$supportedVectorTypes.';

  /// Error for when an embedding generator produces an unsupported type.
  static String embeddingGeneratorWithInvalidEmbeddingType(
    VectorPropertyModel vectorProperty,
  ) =>
      "An embedding generator was configured on property "
      "'${vectorProperty.modelName}', but output embedding type "
      "'${vectorProperty.embeddingType}' isn't supported by the provider.";

  /// Error for when an embedding property type is incompatible with the
  /// configured generator.
  static String embeddingPropertyTypeIncompatibleWithEmbeddingGenerator(
    VectorPropertyModel vectorProperty,
  ) =>
      "Property '${vectorProperty.modelName}' has embedding type "
      "'${_typeName(vectorProperty.type)}', but an embedding generator is "
      'configured on the property. Remove the embedding generator or change '
      "the property's type to a non-embedding input type.";

  /// Error for when [VectorStore.getCollection] is called with a
  /// `Map<String, Object?>` record type on a collection that doesn't support
  /// dynamic mapping.
  static const String getCollectionWithDictionaryNotSupported =
      'Dynamic mapping via Map<String, Object?> is not supported via this '
      'method; call getDynamicCollection() instead.';

  /// Error for when `includeVectors` is enabled while an embedding generator
  /// is configured.
  static const String includeVectorsNotSupportedWithEmbeddingGeneration =
      'When an embedding generator is configured, includeVectors cannot be '
      'enabled.';

  /// Error for when the embedding generator cannot convert the input type to
  /// a supported vector type.
  static String incompatibleEmbeddingGenerator(
    VectorPropertyModel vectorProperty,
    Object embeddingGenerator,
    String supportedOutputTypes,
  ) =>
      "Embedding generator '${_typeName(embeddingGenerator.runtimeType)}' on "
      "vector property '${vectorProperty.modelName}' cannot convert the input "
      "type '${_typeName(vectorProperty.type)}' to a supported vector type "
      '(one of: $supportedOutputTypes).';

  /// Error for when an incompatible embedding generator was configured.
  static String incompatibleEmbeddingGeneratorWasConfiguredForInputType(
    Type inputType,
    Type embeddingGeneratorType,
  ) =>
      "An input of type '${_typeName(inputType)}' was provided, but an "
      "incompatible embedding generator of type "
      "'${_typeName(embeddingGeneratorType)}' was configured.";

  /// Error for when the search input is invalid and no embedding generator
  /// is configured.
  static String invalidSearchInputAndNoEmbeddingGeneratorWasConfigured(
    Type inputType,
    String supportedVectorTypes,
  ) =>
      "A value of type '${_typeName(inputType)}' was passed to searchAsync, "
      "but that isn't a supported vector type by your provider and no "
      'embedding generator was configured. The supported vector types are: '
      '$supportedVectorTypes.';

  /// Error for when [getDynamicCollection] is called on a non-dynamic
  /// collection type.
  static String nonDynamicCollectionWithDictionaryNotSupported(
    Type dynamicCollectionType,
  ) =>
      'Dynamic mapping via Map<String, Object?> is not supported via this '
      "class; use '${_typeName(dynamicCollectionType)}' instead.";

  static String _typeName(Type type) {
    final name = type.toString();
    final chevron = name.indexOf('<');
    return chevron == -1 ? name : name.substring(0, chevron);
  }
}

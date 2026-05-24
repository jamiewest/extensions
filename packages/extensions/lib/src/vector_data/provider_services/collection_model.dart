import 'package:extensions/annotations.dart';

import '../vector_search_options.dart';
import 'data_property_model.dart';
import 'key_property_model.dart';
import 'property_model.dart';
import 'vector_property_model.dart';

/// Represents the runtime model for a vector store record type.
///
/// Built by [CollectionModelBuilder]; consumed by provider implementations
/// to drive serialisation, deserialisation, and embedding generation.
///
/// This is a support type for provider implementors; application code should
/// not reference it directly.
@Source(
  name: 'CollectionModel.cs',
  namespace: 'Microsoft.Extensions.VectorData.ProviderServices',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.VectorData.Abstractions/'
      'ProviderServices/',
)
final class CollectionModel {
  final Object Function() _recordFactory;
  VectorPropertyModel? _singleVectorProperty;
  DataPropertyModel? _singleFullTextSearchProperty;

  /// Creates a [CollectionModel].
  CollectionModel({
    required Object Function() recordFactory,
    required this.keyProperties,
    required this.dataProperties,
    required this.vectorProperties,
    required this.propertyMap,
  })  : _recordFactory = recordFactory,
        embeddingGenerationRequired =
            vectorProperties.any((p) => p.embeddingType != null);

  /// The key properties of the record.
  final List<KeyPropertyModel> keyProperties;

  /// The data properties of the record.
  final List<DataPropertyModel> dataProperties;

  /// The vector properties of the record.
  final List<VectorPropertyModel> vectorProperties;

  /// All properties, indexed by their model name.
  final Map<String, PropertyModel> propertyMap;

  /// All properties of all types.
  Iterable<PropertyModel> get properties => propertyMap.values;

  /// Whether any vector property requires embedding generation.
  final bool embeddingGenerationRequired;

  /// The single key property.
  ///
  /// Throws [StateError] if the record has more than one key property.
  KeyPropertyModel get keyProperty =>
      keyProperties.single;

  /// The single vector property.
  ///
  /// Throws [StateError] if the record has more than one vector property.
  /// Suitable only for providers that validate single-vector collections.
  VectorPropertyModel get vectorProperty =>
      _singleVectorProperty ??= vectorProperties.single;

  /// Creates a new record instance using the factory supplied at build time.
  T createRecord<T>() => _recordFactory() as T;

  /// Returns the vector property named in [options], or the single vector
  /// property when no name is given.
  ///
  /// Throws [StateError] when no name is given and the record has zero or
  /// more than one vector property.
  VectorPropertyModel getVectorPropertyOrSingle<TRecord>(
    VectorSearchOptions<TRecord> options,
  ) {
    final name = options.vectorPropertyName;
    if (name != null) {
      return _requireProperty<VectorPropertyModel>(name);
    }

    return _singleVectorProperty ??= switch (vectorProperties) {
      [final p] => p,
      [] => throw StateError(
          'The record type does not have any vector properties.',
        ),
      _ => throw StateError(
          'The record type has multiple vector properties; specify one via '
          'VectorSearchOptions.vectorPropertyName.',
        ),
    };
  }

  /// Returns the full-text-indexed data property with [propertyName], or
  /// the single such property when [propertyName] is null.
  ///
  /// Throws [StateError] when the resolved property does not have full-text
  /// indexing enabled, or when no name is given and there is not exactly one
  /// full-text-indexed text property.
  DataPropertyModel getFullTextDataPropertyOrSingle(String? propertyName) {
    if (propertyName != null) {
      final prop = _requireProperty<DataPropertyModel>(propertyName);
      if (!prop.isFullTextIndexed) {
        throw StateError(
          "Property '$propertyName' does not have full-text search indexing "
          'enabled.',
        );
      }
      return prop;
    }

    if (_singleFullTextSearchProperty == null) {
      final candidates = dataProperties
          .where(
            (p) => p.type == String && p.isFullTextIndexed,
          )
          .toList();

      _singleFullTextSearchProperty = switch (candidates) {
        [final p] => p,
        [] => throw StateError(
            'The record type does not have any full-text-indexed text '
            'properties.',
          ),
        _ => throw StateError(
            'The record type has multiple full-text-indexed text properties; '
            'specify one by name.',
          ),
      };
    }

    return _singleFullTextSearchProperty!;
  }

  /// Returns the property with [name].
  ///
  /// Throws [StateError] when no property with that name exists.
  PropertyModel getProperty(String name) => _requireProperty(name);

  T _requireProperty<T extends PropertyModel>(String name) {
    final prop = propertyMap[name];
    if (prop == null) {
      throw StateError("Property '$name' could not be found.");
    }
    if (prop is! T) {
      throw StateError(
        "Property '$name' is not of the expected type $T.",
      );
    }
    return prop;
  }
}

import 'embedding_generator_metadata.dart';

/// Represents a generator of embeddings.
///
/// Remarks: This base interface is used to allow for embedding generators to
/// be stored in a non-generic manner. To use the generator to create
/// embeddings, instances typed as this base interface first need to be cast
/// to the generic interface [EmbeddingGenerator].
abstract class EmbeddingGenerator implements Disposable {
  /// Asks the [EmbeddingGenerator] for an object of the specified type
  /// `serviceType`.
  ///
  /// Remarks: The purpose of this method is to allow for the retrieval of
  /// strongly typed services that might be provided by the
  /// [EmbeddingGenerator], including itself or any services it might be
  /// wrapping. For example, to access the [EmbeddingGeneratorMetadata] for the
  /// instance, [Object)] may be used to request it.
  ///
  /// Returns: The found object, otherwise `null`.
  ///
  /// [serviceType] The type of object being requested.
  ///
  /// [serviceKey] An optional key that can be used to help identify the target
  /// service.
  Object? getService(Type serviceType, {Object? serviceKey});
}

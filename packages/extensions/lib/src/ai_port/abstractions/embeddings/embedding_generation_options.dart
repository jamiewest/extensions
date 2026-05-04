import '../../../../../../lib/func_typedefs.dart';

/// Represents the options for an embedding generation request.
class EmbeddingGenerationOptions {
  /// Initializes a new instance of the [EmbeddingGenerationOptions] class,
  /// performing a shallow copy of all properties from `other`.
  EmbeddingGenerationOptions(EmbeddingGenerationOptions? other) : additionalProperties = other.additionalProperties?.clone(), dimensions = other.dimensions, modelId = other.modelId, rawRepresentationFactory = other.rawRepresentationFactory {
    if (other == null) {
      return;
    }
  }

  /// Gets or sets the number of dimensions requested in the embedding.
  int? dimensions;

  /// Gets or sets the model ID for the embedding generation request.
  String? modelId;

  /// Gets or sets additional properties for the embedding generation request.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets or sets a callback responsible for creating the raw representation of
  /// the embedding generation options from an underlying implementation.
  ///
  /// Remarks: The underlying [EmbeddingGenerator] implementation may have its
  /// own representation of options. When [CancellationToken)] is invoked with
  /// an [EmbeddingGenerationOptions], that implementation may convert the
  /// provided options into its own representation in order to use it while
  /// performing the operation. For situations where a consumer knows which
  /// concrete [EmbeddingGenerator] is being used and how it represents options,
  /// a new instance of that implementation-specific options type may be
  /// returned by this callback, for the [EmbeddingGenerator] implementation to
  /// use instead of creating a new instance. Such implementations may mutate
  /// the supplied options instance further based on other settings supplied on
  /// this [EmbeddingGenerationOptions] instance or from other inputs,
  /// therefore, it is strongly recommended to not return shared instances and
  /// instead make the callback return a new instance on each call. This is
  /// typically used to set an implementation-specific setting that isn't
  /// otherwise exposed from the strongly typed properties on
  /// [EmbeddingGenerationOptions].
  Func<EmbeddingGenerator, Object?>? rawRepresentationFactory;

  /// Produces a clone of the current [EmbeddingGenerationOptions] instance.
  ///
  /// Remarks: The clone will have the same values for all properties as the
  /// original instance. Any collections, like [AdditionalProperties] are
  /// shallow-cloned, meaning a new collection instance is created, but any
  /// references contained by the collections are shared with the original.
  ///
  /// Returns: A clone of the current [EmbeddingGenerationOptions] instance.
  EmbeddingGenerationOptions clone() {
    return new(this);
  }
}

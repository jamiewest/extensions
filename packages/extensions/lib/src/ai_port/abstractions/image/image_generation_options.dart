import '../../../../../../lib/func_typedefs.dart';
import 'image_generator.dart';

/// Represents the options for an image generation request.
class ImageGenerationOptions {
  /// Initializes a new instance of the [ImageGenerationOptions] class,
  /// performing a shallow copy of all properties from `other`.
  ImageGenerationOptions(ImageGenerationOptions? other) : additionalProperties = other.additionalProperties?.clone(), count = other.count, imageSize = other.imageSize, mediaType = other.mediaType, modelId = other.modelId, rawRepresentationFactory = other.rawRepresentationFactory, responseFormat = other.responseFormat {
    if (other == null) {
      return;
    }
  }

  /// Gets or sets the number of images to generate.
  int? count;

  /// Gets or sets the size of the generated image.
  ///
  /// Remarks: If a provider only supports fixed sizes, the closest supported
  /// size is used.
  Size? imageSize;

  /// Gets or sets the media type (also known as MIME type) of the generated
  /// image.
  String? mediaType;

  /// Gets or sets the model ID to use for image generation.
  String? modelId;

  /// Gets or sets a callback responsible for creating the raw representation of
  /// the image generation options from an underlying implementation.
  ///
  /// Remarks: The underlying [ImageGenerator] implementation can have its own
  /// representation of options. When [CancellationToken)] is invoked with an
  /// [ImageGenerationOptions], that implementation can convert the provided
  /// options into its own representation in order to use it while performing
  /// the operation. For situations where a consumer knows which concrete
  /// [ImageGenerator] is being used and how it represents options, a new
  /// instance of that implementation-specific options type can be returned by
  /// this callback for the [ImageGenerator] implementation to use instead of
  /// creating a new instance. Such implementations might mutate the supplied
  /// options instance further based on other settings supplied on this
  /// [ImageGenerationOptions] instance or from other inputs, therefore, it is
  /// strongly recommended to not return shared instances and instead make the
  /// callback return a new instance on each call. This is typically used to set
  /// an implementation-specific setting that isn't otherwise exposed from the
  /// strongly typed properties on [ImageGenerationOptions].
  Func<ImageGenerator, Object?>? rawRepresentationFactory;

  /// Gets or sets the response format of the generated image.
  ImageGenerationResponseFormat? responseFormat;

  /// Gets or sets the number of intermediate streaming images to generate.
  int? streamingCount;

  /// Gets or sets any additional properties associated with the options.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Produces a clone of the current [ImageGenerationOptions] instance.
  ///
  /// Returns: A clone of the current [ImageGenerationOptions] instance.
  ImageGenerationOptions clone() {
    return new(this);
  }
}
/// Represents the requested response format of the generated image.
///
/// Remarks: Not all implementations support all response formats and this
/// value might be ignored by the implementation if not supported.
enum ImageGenerationResponseFormat { /// The generated image is returned as a URI pointing to the image resource.
uri,
/// The generated image is returned as in-memory image data.
data,
/// The generated image is returned as a hosted resource identifier, which can
/// be used to retrieve the image later.
hosted }

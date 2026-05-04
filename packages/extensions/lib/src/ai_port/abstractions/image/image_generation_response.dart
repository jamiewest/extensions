import '../contents/ai_content.dart';
import '../contents/data_content.dart';
import '../contents/uri_content.dart';
import '../usage_details.dart';

/// Represents the result of an image generation request.
class ImageGenerationResponse {
  /// Initializes a new instance of the [ImageGenerationResponse] class.
  ///
  /// [contents] The contents for this response.
  const ImageGenerationResponse(List<AContent>? contents) : contents = contents;

  /// Gets or sets the raw representation of the image generation response from
  /// an underlying implementation.
  ///
  /// Remarks: If a [ImageGenerationResponse] is created to represent some
  /// underlying object from another object model, this property can be used to
  /// store that original object. This can be useful for debugging or for
  /// enabling a consumer to access the underlying object model if needed.
  Object? rawRepresentation;

  /// Gets or sets the generated content items.
  ///
  /// Remarks: Content is typically [DataContent] for images streamed from the
  /// generator, or [UriContent] for remotely hosted images, but can also be
  /// provider-specific content types that represent the generated images.
  List<AContent> contents;

  /// Gets or sets usage details for the image generation response.
  UsageDetails? usage;
}

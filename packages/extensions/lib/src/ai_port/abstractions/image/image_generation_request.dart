import '../contents/ai_content.dart';

/// Represents a request for image generation.
class ImageGenerationRequest {
  /// Initializes a new instance of the [ImageGenerationRequest] class.
  ///
  /// [prompt] The prompt to guide the image generation.
  ///
  /// [originalImages] The original images to base edits on.
  ImageGenerationRequest({
    String? prompt = null,
    Iterable<AContent>? originalImages = null,
  }) : prompt = prompt,
       originalImages = originalImages;

  /// Gets or sets the prompt to guide the image generation.
  String? prompt;

  /// Gets or sets the original images to base edits on.
  ///
  /// Remarks: If this property is set, the request will behave as an image edit
  /// operation. If this property is null or empty, the request will behave as a
  /// new image generation operation.
  Iterable<AContent>? originalImages;
}

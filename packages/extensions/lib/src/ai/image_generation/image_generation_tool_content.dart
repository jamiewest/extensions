import '../ai_content.dart';

/// Represents an image generation tool call by a hosted service.
///
/// This is an experimental feature.
class ImageGenerationToolCallContent extends AIContent {
  /// Creates a new [ImageGenerationToolCallContent].
  ImageGenerationToolCallContent({
    this.imageId,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The identifier of the generated image.
  final String? imageId;

  @override
  String toString() => 'ImageGenerationToolCall($imageId)';
}

/// Represents the result of an image generation tool call.
///
/// This is an experimental feature.
class ImageGenerationToolResultContent extends AIContent {
  /// Creates a new [ImageGenerationToolResultContent].
  ImageGenerationToolResultContent({
    this.imageId,
    this.outputs,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The identifier of the generated image.
  final String? imageId;

  /// The output content items.
  final List<AIContent>? outputs;

  @override
  String toString() => 'ImageGenerationToolResult($imageId)';
}

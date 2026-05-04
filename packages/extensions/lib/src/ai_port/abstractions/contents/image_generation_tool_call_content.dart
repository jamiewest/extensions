import 'tool_call_content.dart';

/// Represents the invocation of an image generation tool call by a hosted
/// service.
class ImageGenerationToolCallContent extends ToolCallContent {
  /// Initializes a new instance of the [ImageGenerationToolCallContent] class.
  ///
  /// [callId] The tool call ID.
  const ImageGenerationToolCallContent(String callId);
}

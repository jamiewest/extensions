import 'ai_content.dart';
import 'data_content.dart';
import 'tool_result_content.dart';
import 'uri_content.dart';

/// Represents the result of an image generation tool invocation by a hosted
/// service.
///
/// Remarks: This content type is used to represent the result of an image
/// generation tool invocation by a hosted service. It is informational only.
class ImageGenerationToolResultContent extends ToolResultContent {
  /// Initializes a new instance of the [ImageGenerationToolResultContent]
  /// class.
  ///
  /// [callId] The tool call ID.
  const ImageGenerationToolResultContent(String callId);

  /// Gets or sets the generated content items.
  ///
  /// Remarks: Content is typically [DataContent] for images streamed from the
  /// tool, or [UriContent] for remotely hosted images, but can also be
  /// provider-specific content types that represent the generated images.
  List<AContent>? outputs;
}

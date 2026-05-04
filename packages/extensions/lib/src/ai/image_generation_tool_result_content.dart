import 'package:extensions/annotations.dart';

import 'ai_content.dart';
import 'tool_result_content.dart';

/// Represents the result of an image generation tool invocation by a hosted
/// service.
///
/// Outputs are typically [DataContent] for streamed images or [UriContent]
/// for remotely hosted images.
@Source(
  name: 'ImageGenerationToolResultContent.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Contents/',
)
class ImageGenerationToolResultContent extends ToolResultContent {
  /// Creates a new [ImageGenerationToolResultContent].
  ImageGenerationToolResultContent({
    required super.callId,
    this.outputs,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The generated content items (images as [DataContent] or [UriContent]).
  List<AIContent>? outputs;
}

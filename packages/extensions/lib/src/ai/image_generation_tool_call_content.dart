import 'package:extensions/annotations.dart';

import 'tool_call_content.dart';

/// Represents an image generation tool call invoked by a hosted service.
///
/// This is informational only and represents the call itself, not its result.
@Source(
  name: 'ImageGenerationToolCallContent.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Contents/',
)
class ImageGenerationToolCallContent extends ToolCallContent {
  /// Creates a new [ImageGenerationToolCallContent].
  ImageGenerationToolCallContent({
    required super.callId,
    this.prompt,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The image generation prompt or description.
  String? prompt;
}

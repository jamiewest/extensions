import '../image_generation/image_generator.dart';
import 'ai_tool.dart';

/// A tool representing a hosted image generation capability.
///
/// This is an experimental feature.
class HostedImageGenerationTool extends AITool {
  /// Creates a new [HostedImageGenerationTool].
  HostedImageGenerationTool({
    this.options,
  }) : super(
            name: 'image_generation', description: 'Image generation');

  /// Options for image generation.
  final ImageGenerationOptions? options;
}

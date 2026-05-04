import '../image/image_generation_options.dart';
import 'ai_tool.dart';

/// Represents a hosted tool that can be specified to an AI service to enable
/// it to perform image generation.
///
/// Remarks: This tool does not itself implement image generation. It is a
/// marker that can be used to inform a service that the service is allowed to
/// perform image generation if the service is capable of doing so.
class HostedImageGenerationTool extends ATool {
  /// Initializes a new instance of the [HostedImageGenerationTool] class.
  ///
  /// [additionalProperties] Any additional properties associated with the tool.
  HostedImageGenerationTool(Map<String, Object?>? additionalProperties)
    : additionalProperties = additionalProperties,
      _additionalProperties = additionalProperties;

  /// Any additional properties associated with the tool.
  Map<String, Object?>? _additionalProperties;

  /// Gets or sets the options used to configure image generation.
  ImageGenerationOptions? options;

  String get name {
    return "image_generation";
  }

  Map<String, Object?> get additionalProperties {
    return _additionalProperties ?? base.additionalProperties;
  }
}

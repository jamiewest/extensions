import '../../system/disposable.dart';
import '../../system/threading/cancellation_token.dart';
import '../additional_properties_dictionary.dart';
import '../ai_content.dart';
import '../usage_details.dart';

/// Options for image generation requests.
///
/// This is an experimental feature.
class ImageGenerationOptions {
  /// Creates a new [ImageGenerationOptions].
  ImageGenerationOptions({
    this.count,
    this.imageWidth,
    this.imageHeight,
    this.mediaType,
    this.modelId,
    this.additionalProperties,
  });

  /// The number of images to generate.
  int? count;

  /// The width of the generated image.
  int? imageWidth;

  /// The height of the generated image.
  int? imageHeight;

  /// The MIME type of the generated image.
  String? mediaType;

  /// The model to use for generation.
  String? modelId;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Creates a deep copy of this [ImageGenerationOptions].
  ImageGenerationOptions clone() => ImageGenerationOptions(
        count: count,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        mediaType: mediaType,
        modelId: modelId,
        additionalProperties: additionalProperties != null
            ? Map.of(additionalProperties!)
            : null,
      );
}

/// Represents an image generation request.
///
/// This is an experimental feature.
class ImageGenerationRequest {
  /// Creates a new [ImageGenerationRequest].
  ImageGenerationRequest({this.prompt, this.originalImages});

  /// The generation prompt.
  String? prompt;

  /// Original images for editing operations.
  Iterable<AIContent>? originalImages;
}

/// Represents an image generation response.
///
/// This is an experimental feature.
class ImageGenerationResponse {
  /// Creates a new [ImageGenerationResponse].
  ImageGenerationResponse({
    List<AIContent>? contents,
    this.rawRepresentation,
    this.usage,
  }) : contents = contents ?? [];

  /// The generated image contents.
  final List<AIContent> contents;

  /// The underlying implementation-specific object.
  Object? rawRepresentation;

  /// Usage details.
  UsageDetails? usage;
}

/// Represents an image generator.
///
/// This is an experimental feature.
abstract class ImageGenerator implements Disposable {
  /// Generates images based on the given [request].
  Future<ImageGenerationResponse> generate({
    required ImageGenerationRequest request,
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Gets a service of the specified type.
  T? getService<T>({Object? key}) => null;
}

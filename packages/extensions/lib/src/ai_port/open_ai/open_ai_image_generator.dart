import '../abstractions/contents/data_content.dart';
import '../abstractions/contents/uri_content.dart';
import '../abstractions/image/image_generation_options.dart';
import '../abstractions/image/image_generation_request.dart';
import '../abstractions/image/image_generation_response.dart';
import '../abstractions/image/image_generator.dart';
import '../abstractions/image/image_generator_metadata.dart';

/// Represents an [ImageGenerator] for an OpenAI [OpenAIClient] or
/// [ImageClient].
class OpenAImageGenerator implements ImageGenerator {
  /// Initializes a new instance of the [OpenAIImageGenerator] class for the
  /// specified [ImageClient].
  ///
  /// [imageClient] The underlying client.
  const OpenAImageGenerator(ImageClient imageClient) : _imageClient = Throw.ifNull(imageClient), _metadata = new("openai", imageClient.endpoint, _imageClient.model);

  /// Metadata about the client.
  final ImageGeneratorMetadata _metadata;

  /// The underlying [ImageClient].
  final ImageClient _imageClient;

  @override
  Future<ImageGenerationResponse> generate(
    ImageGenerationRequest request,
    {ImageGenerationOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(request);
    var prompt = request.prompt;
    _ = Throw.ifNull(prompt);
    if (request.originalImages != null && request.originalImages.any()) {
      var editOptions = toOpenAIImageEditOptions(options);
      var fileName = null;
      var imageStream = null;
      var originalImage = request.originalImages.firstOrDefault();
      if (originalImage is DataContent) {
        final dataContent = originalImage as DataContent;
        imageStream = MemoryMarshal.tryGetArray(dataContent.data, out var array) ?
                    memoryStream(array.array!, array.offset, array.count) :
                    memoryStream(dataContent.data.toArray());
        fileName =
                    dataContent.name ??
                    '${Guid.newGuid():N}${MediaTypeMap.getExtension(dataContent.mediaType) ?? ".png"}';
      }
      var editResult = await _imageClient.generateImageEditsAsync(
                imageStream, fileName, prompt, options?.count ?? 1, editOptions, cancellationToken).configureAwait(false);
      return toImageGenerationResponse(editResult);
    }
    var openAIOptions = toOpenAIImageGenerationOptions(options);
    var result = await _imageClient.generateImagesAsync(
      prompt,
      options?.count ?? 1,
      openAIOptions,
      cancellationToken,
    ) .configureAwait(false);
    return toImageGenerationResponse(result);
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey, }) {
    return serviceType == null ? throw argumentNullException(nameof(serviceType)) :
        serviceKey != null ? null :
        serviceType == typeof(ImageGeneratorMetadata) ? _metadata :
        serviceType == typeof(ImageClient) ? _imageClient :
        serviceType.isInstanceOfType(this) ? this :
        null;
  }

  void dispose() {

  }

  /// Converts a [Size] to an OpenAI [GeneratedImageSize].
  ///
  /// Returns: Closest supported size.
  ///
  /// [requestedSize] User's requested size.
  static GeneratedImageSize? toOpenAIImageSize(Size? requestedSize) {
    return requestedSize == null ? null : generatedImageSize(
      requestedSize.value.width,
      requestedSize.value.height,
    );
  }

  /// Converts a [GeneratedImageCollection] to a [ImageGenerationResponse].
  static ImageGenerationResponse toImageGenerationResponse(GeneratedImageCollection generatedImages) {
    var contentType = generatedImages.outputFileFormat?.toString() is { } outputFormat ?
            'image/${outputFormat}' :
            "image/png";
    var contents = [];
    for (final image in generatedImages) {
      if (image.imageBytes != null) {
        contents.add(dataContent(image.imageBytes.toMemory(), contentType));
      } else if (image.imageUri != null) {
        contents.add(uriContent(image.imageUri, contentType));
      } else {
        throw invalidOperationException("Generated image does not contain a valid URI or byte array.");
      }
    }
    var ud = null;
    if (generatedImages.usage is { } usage) {
      ud = new()
            {
                InputTokenCount = usage.inputTokenCount,
                OutputTokenCount = usage.outputTokenCount,
                TotalTokenCount = usage.totalTokenCount,
            };
      if (usage.inputTokenDetails is { } inputDetails) {
        ud.additionalCounts ??= [];
        ud.additionalCounts.add(
          '${nameof(usage.inputTokenDetails)}.${nameof(inputDetails.imageTokenCount)}',
          inputDetails.imageTokenCount,
        );
        ud.additionalCounts.add(
          '${nameof(usage.inputTokenDetails)}.${nameof(inputDetails.textTokenCount)}',
          inputDetails.textTokenCount,
        );
      }
    }
    return imageGenerationResponse(contents);
  }

  /// Converts a [ImageGenerationOptions] to a [ImageGenerationOptions].
  ImageGenerationOptions toOpenAIImageGenerationOptions(ImageGenerationOptions? options) {
    var result = options?.rawRepresentationFactory?.invoke(this) as OpenAI.images.imageGenerationOptions ?? new();
    if (result.outputFileFormat == null) {
      if (options?.mediaType?.equals("image/png", StringComparison.ordinalIgnoreCase) is true) {
        result.outputFileFormat = GeneratedImageFileFormat.png;
      } else if (options?.mediaType?.equals("image/jpeg", StringComparison.ordinalIgnoreCase) is true) {
        result.outputFileFormat = GeneratedImageFileFormat.jpeg;
      } else if (options?.mediaType?.equals("image/webp", StringComparison.ordinalIgnoreCase) is true) {
        result.outputFileFormat = GeneratedImageFileFormat.webp;
      }
    }
    result.responseFormat ??= options?.responseFormat switch
        {
            ImageGenerationResponseFormat.uri => GeneratedImageFormat.uri,
            ImageGenerationResponseFormat.data => GeneratedImageFormat.bytes,
            (_) => (GeneratedImageFormat?)null
        };
    result.size ??= toOpenAIImageSize(options?.imageSize);
    return result;
  }

  /// Converts a [ImageGenerationOptions] to a [ImageEditOptions].
  ImageEditOptions toOpenAIImageEditOptions(ImageGenerationOptions? options) {
    var result = options?.rawRepresentationFactory?.invoke(this) as ImageEditOptions ?? new();
    if (result.outputFileFormat == null) {
      if (options?.mediaType?.equals("image/png", StringComparison.ordinalIgnoreCase) is true) {
        result.outputFileFormat = GeneratedImageFileFormat.png;
      } else if (options?.mediaType?.equals("image/jpeg", StringComparison.ordinalIgnoreCase) is true) {
        result.outputFileFormat = GeneratedImageFileFormat.jpeg;
      } else if (options?.mediaType?.equals("image/webp", StringComparison.ordinalIgnoreCase) is true) {
        result.outputFileFormat = GeneratedImageFileFormat.webp;
      }
    }
    result.responseFormat ??= options?.responseFormat switch
        {
            ImageGenerationResponseFormat.uri => GeneratedImageFormat.uri,
            ImageGenerationResponseFormat.data => GeneratedImageFormat.bytes,
            (_) => (GeneratedImageFormat?)null
        };
    result.size ??= toOpenAIImageSize(options?.imageSize);
    return result;
  }
}

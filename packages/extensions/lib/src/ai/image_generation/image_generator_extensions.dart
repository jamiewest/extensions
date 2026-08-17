import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../ai_content.dart';
import '../data_content.dart';
import 'image_generator.dart';

/// Convenience operations for [ImageGenerator].
///
/// The upstream overload taking raw bytes plus a file name (which infers a
/// media type via `MediaTypeMap`) is not ported — construct a [DataContent]
/// with an explicit `mediaType` and use [editImage] instead.
///
/// This is an experimental feature.
@Source(
  name: 'ImageGeneratorExtensions.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Image/',
)
extension ImageGeneratorExtensions on ImageGenerator {
  /// Generates images from a text [prompt].
  Future<ImageGenerationResponse> generateImages(
    String prompt, {
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) => generate(
    request: ImageGenerationRequest(prompt: prompt),
    options: options,
    cancellationToken: cancellationToken,
  );

  /// Edits a single [originalImage] according to [prompt].
  Future<ImageGenerationResponse> editImage(
    DataContent originalImage,
    String prompt, {
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) => editImages(
    [originalImage],
    prompt,
    options: options,
    cancellationToken: cancellationToken,
  );

  /// Edits [originalImages] according to [prompt].
  Future<ImageGenerationResponse> editImages(
    Iterable<AIContent> originalImages,
    String prompt, {
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) => generate(
    request: ImageGenerationRequest(
      prompt: prompt,
      originalImages: originalImages,
    ),
    options: options,
    cancellationToken: cancellationToken,
  );
}

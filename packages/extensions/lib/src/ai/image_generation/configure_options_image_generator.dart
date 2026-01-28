import '../../system/threading/cancellation_token.dart';
import 'delegating_image_generator.dart';
import 'image_generator.dart';

/// A delegating image generator that applies configuration to
/// [ImageGenerationOptions] before each request.
///
/// This is an experimental feature.
class ConfigureOptionsImageGenerator extends DelegatingImageGenerator {
  /// Creates a new [ConfigureOptionsImageGenerator].
  ///
  /// [configure] is called before each request to modify the options.
  ConfigureOptionsImageGenerator(
    super.innerGenerator, {
    required this.configure,
  });

  /// The callback that configures options before each request.
  final ImageGenerationOptions Function(ImageGenerationOptions options)
      configure;

  @override
  Future<ImageGenerationResponse> generate({
    required ImageGenerationRequest request,
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      super.generate(
        request: request,
        options: configure(options ?? ImageGenerationOptions()),
        cancellationToken: cancellationToken,
      );
}

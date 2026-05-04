import '../../../../../lib/func_typedefs.dart';
import '../abstractions/image/delegating_image_generator.dart';
import '../abstractions/image/image_generation_options.dart';
import '../abstractions/image/image_generation_request.dart';
import '../abstractions/image/image_generation_response.dart';
import '../abstractions/image/image_generator.dart';

/// Represents a delegating image generator that configures a
/// [ImageGenerationOptions] instance used by the remainder of the pipeline.
class ConfigureOptionsImageGenerator extends DelegatingImageGenerator {
  /// Initializes a new instance of the [ConfigureOptionsImageGenerator] class
  /// with the specified `configure` callback.
  ///
  /// Remarks: The `configure` delegate is passed either a new instance of
  /// [ImageGenerationOptions] if the caller didn't supply a
  /// [ImageGenerationOptions] instance, or a clone (via [Clone] of the
  /// caller-supplied instance if one was supplied.
  ///
  /// [innerGenerator] The inner generator.
  ///
  /// [configure] The delegate to invoke to configure the
  /// [ImageGenerationOptions] instance. It is passed a clone of the
  /// caller-supplied [ImageGenerationOptions] instance (or a newly constructed
  /// instance if the caller-supplied instance is `null`).
  const ConfigureOptionsImageGenerator(
    ImageGenerator innerGenerator,
    Action<ImageGenerationOptions> configure,
  ) : _configureOptions = Throw.ifNull(configure);

  /// The callback delegate used to configure options.
  final Action<ImageGenerationOptions> _configureOptions;

  @override
  Future<ImageGenerationResponse> generate(
    ImageGenerationRequest request,
    {ImageGenerationOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    return await base.generateAsync(request, configure(options), cancellationToken);
  }

  /// Creates and configures the [ImageGenerationOptions] to pass along to the
  /// inner generator.
  ImageGenerationOptions configure(ImageGenerationOptions? options) {
    options = options?.clone() ?? new();
    _configureOptions(options);
    return options;
  }
}

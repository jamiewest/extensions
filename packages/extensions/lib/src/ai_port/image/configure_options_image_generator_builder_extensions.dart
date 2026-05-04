import '../../../../../lib/func_typedefs.dart';
import '../abstractions/image/image_generation_options.dart';
import 'configure_options_image_generator.dart';
import 'image_generator_builder.dart';

/// Provides extensions for configuring [ConfigureOptionsImageGenerator]
/// instances.
extension ConfigureOptionsImageGeneratorBuilderExtensions
    on ImageGeneratorBuilder {
  /// Adds a callback that configures a [ImageGenerationOptions] to be passed to
  /// the next generator in the pipeline.
  ///
  /// Remarks: This method can be used to set default options. The `configure`
  /// delegate is passed either a new instance of [ImageGenerationOptions] if
  /// the caller didn't supply a [ImageGenerationOptions] instance, or a clone
  /// (via [Clone]) of the caller-supplied instance if one was supplied.
  ///
  /// Returns: The `builder`.
  ///
  /// [builder] The [ImageGeneratorBuilder].
  ///
  /// [configure] The delegate to invoke to configure the
  /// [ImageGenerationOptions] instance. It is passed a clone of the
  /// caller-supplied [ImageGenerationOptions] instance (or a newly constructed
  /// instance if the caller-supplied instance is `null`).
  ImageGeneratorBuilder configureOptions(
    Action<ImageGenerationOptions> configure,
  ) {
    _ = Throw.ifNull(builder);
    _ = Throw.ifNull(configure);
    return builder.use(
      (innerGenerator) =>
          configureOptionsImageGenerator(innerGenerator, configure),
    );
  }
}

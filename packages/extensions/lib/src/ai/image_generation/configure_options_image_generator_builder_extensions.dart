import 'configure_options_image_generator.dart';
import 'image_generator.dart';
import 'image_generator_builder.dart';

/// Provides extensions for adding [ConfigureOptionsImageGenerator] to an
/// [ImageGeneratorBuilder] pipeline.
///
/// This is an experimental feature.
extension ConfigureOptionsImageGeneratorBuilderExtensions
    on ImageGeneratorBuilder {
  /// Adds a callback that configures the [ImageGenerationOptions] passed to
  /// each request.
  ImageGeneratorBuilder useConfigureOptions(
    ImageGenerationOptions Function(ImageGenerationOptions options) configure,
  ) => use(
    (inner) => ConfigureOptionsImageGenerator(inner, configure: configure),
  );
}

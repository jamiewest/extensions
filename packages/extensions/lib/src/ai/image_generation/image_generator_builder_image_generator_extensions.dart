import 'image_generator.dart';
import 'image_generator_builder.dart';

/// Provides extension methods for working with [ImageGenerator] in the
/// context of [ImageGeneratorBuilder].
///
/// This is an experimental feature.
extension ImageGeneratorBuilderImageGeneratorExtensions on ImageGenerator {
  /// Creates a new [ImageGeneratorBuilder] using this generator as its
  /// inner generator.
  ImageGeneratorBuilder asBuilder() => ImageGeneratorBuilder(this);
}

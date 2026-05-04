import '../abstractions/image/image_generator.dart';
import 'image_generator_builder.dart';

/// Provides extension methods for working with [ImageGenerator] in the
/// context of [ImageGeneratorBuilder].
extension ImageGeneratorBuilderImageGeneratorExtensions on ImageGenerator {
  /// Creates a new [ImageGeneratorBuilder] using `innerGenerator` as its inner
  /// generator.
  ///
  /// Remarks: This method is equivalent to using the [ImageGeneratorBuilder]
  /// constructor directly, specifying `innerGenerator` as the inner generator.
  ///
  /// Returns: The new [ImageGeneratorBuilder] instance.
  ///
  /// [innerGenerator] The generator to use as the inner generator.
  ImageGeneratorBuilder asBuilder() {
    _ = Throw.ifNull(innerGenerator);
    return imageGeneratorBuilder(innerGenerator);
  }
}

import '../../../../../lib/func_typedefs.dart';
import '../abstractions/image/image_generator.dart';
import '../empty_service_provider.dart';

/// A builder for creating pipelines of [ImageGenerator].
class ImageGeneratorBuilder {
  /// Initializes a new instance of the [ImageGeneratorBuilder] class.
  ///
  /// [innerGenerator] The inner [ImageGenerator] that represents the underlying
  /// backend.
  ImageGeneratorBuilder({ImageGenerator? innerGenerator = null, Func<ServiceProvider, ImageGenerator>? innerGeneratorFactory = null, }) : _innerGeneratorFactory = _ => innerGenerator {
    _ = Throw.ifNull(innerGenerator);
  }

  final Func<ServiceProvider, ImageGenerator> _innerGeneratorFactory;

  /// The registered generator factory instances.
  List<Func2<ImageGenerator, ServiceProvider, ImageGenerator>>? _generatorFactories;

  /// Builds an [ImageGenerator] that represents the entire pipeline. Calls to
  /// this instance will pass through each of the pipeline stages in turn.
  ///
  /// Returns: An instance of [ImageGenerator] that represents the entire
  /// pipeline.
  ///
  /// [services] The [ServiceProvider] that should provide services to the
  /// [ImageGenerator] instances. If null, an empty [ServiceProvider] will be
  /// used.
  ImageGenerator build({ServiceProvider? services}) {
    services ??= EmptyServiceProvider.instance;
    var imageGenerator = _innerGeneratorFactory(services);
    if (_generatorFactories != null) {
      for (var i = _generatorFactories.count - 1; i >= 0; i--) {
        imageGenerator = _generatorFactories[i](imageGenerator, services) ??
                    throw invalidOperationException(
                        'The ${nameof(ImageGeneratorBuilder)} entry at index ${i} returned null. ' +
                        'Ensure that the callbacks passed to ${nameof(Use)} return non-null ${nameof(IImageGenerator)} instances.');
      }
    }
    return imageGenerator;
  }

  /// Adds a factory for an intermediate image generator to the image generator
  /// pipeline.
  ///
  /// Returns: The updated [ImageGeneratorBuilder] instance.
  ///
  /// [generatorFactory] The generator factory function.
  ImageGeneratorBuilder use({Func<ImageGenerator, ImageGenerator>? generatorFactory}) {
    _ = Throw.ifNull(generatorFactory);
    return use((innerGenerator, _) => generatorFactory(innerGenerator));
  }
}

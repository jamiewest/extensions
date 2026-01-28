import '../../dependency_injection/service_provider.dart';
import '../empty_service_provider.dart';
import 'image_generator.dart';

/// A factory that creates an [ImageGenerator] from a [ServiceProvider].
typedef InnerImageGeneratorFactory = ImageGenerator Function(
    ServiceProvider services);

/// Builds a pipeline of image generator middleware.
///
/// The pipeline is composed by calling [use] one or more times, then
/// calling [build] to produce the final [ImageGenerator]. Middleware
/// factories are applied in reverse order so that the first call to
/// [use] produces the outermost wrapper.
///
/// This is an experimental feature.
class ImageGeneratorBuilder {
  late final InnerImageGeneratorFactory _innerFactory;

  ImageGeneratorBuilder._(InnerImageGeneratorFactory innerFactory)
      : _innerFactory = innerFactory;

  /// Creates a new [ImageGeneratorBuilder] wrapping [innerGenerator].
  ImageGeneratorBuilder(ImageGenerator innerGenerator) {
    _innerFactory = (services) => innerGenerator;
  }

  /// Creates a new [ImageGeneratorBuilder] from a factory function.
  factory ImageGeneratorBuilder.fromFactory(
          InnerImageGeneratorFactory innerFactory) =>
      ImageGeneratorBuilder._(innerFactory);

  final List<ImageGenerator Function(ImageGenerator)> _factories = [];

  /// Adds a middleware factory to the pipeline.
  ImageGeneratorBuilder use(
      ImageGenerator Function(ImageGenerator) factory) {
    _factories.add(factory);
    return this;
  }

  /// Builds the pipeline and returns the outermost [ImageGenerator].
  ImageGenerator build([ServiceProvider? services]) {
    services ??= EmptyServiceProvider.instance;

    var generator = _innerFactory(services);
    for (var i = _factories.length - 1; i >= 0; i--) {
      generator = _factories[i](generator);
    }
    return generator;
  }
}

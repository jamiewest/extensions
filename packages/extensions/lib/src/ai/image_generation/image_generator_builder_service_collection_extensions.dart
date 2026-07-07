import '../../dependency_injection/service_collection.dart';
import '../../dependency_injection/service_descriptor.dart';
import '../../dependency_injection/service_lifetime.dart';
import 'image_generator.dart';
import 'image_generator_builder.dart';

/// Provides extension methods for registering [ImageGenerator] with a
/// [ServiceCollection].
///
/// This is an experimental feature.
extension ImageGeneratorBuilderServiceCollectionExtensions
    on ServiceCollection {
  /// Registers an [ImageGenerator] in the service collection and returns an
  /// [ImageGeneratorBuilder] for adding middleware to the pipeline.
  ImageGeneratorBuilder addImageGenerator(
    InnerImageGeneratorFactory innerGeneratorFactory, [
    ServiceLifetime lifetime = ServiceLifetime.singleton,
  ]) {
    final builder = ImageGeneratorBuilder.fromFactory(innerGeneratorFactory);
    add(switch (lifetime) {
      ServiceLifetime.singleton => ServiceDescriptor.singleton<ImageGenerator>(
          (sp) => builder.build(sp),
        ),
      ServiceLifetime.scoped => ServiceDescriptor.scoped<ImageGenerator>(
          (sp) => builder.build(sp),
        ),
      ServiceLifetime.transient => ServiceDescriptor.transient<ImageGenerator>(
          (sp) => builder.build(sp),
        ),
    });
    return builder;
  }
}

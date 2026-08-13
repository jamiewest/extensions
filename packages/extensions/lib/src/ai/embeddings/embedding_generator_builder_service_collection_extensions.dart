import '../../dependency_injection/service_collection.dart';
import '../../dependency_injection/service_descriptor.dart';
import '../../dependency_injection/service_lifetime.dart';
import 'embedding_generator.dart';
import 'embedding_generator_builder.dart';

/// Provides extension methods for registering [EmbeddingGenerator] with a
/// [ServiceCollection].
extension EmbeddingGeneratorBuilderServiceCollectionExtensions
    on ServiceCollection {
  /// Registers an [EmbeddingGenerator] in the service collection and
  /// returns an [EmbeddingGeneratorBuilder] for adding middleware to the
  /// pipeline.
  EmbeddingGeneratorBuilder addEmbeddingGenerator(
    InnerEmbeddingGeneratorFactory innerGeneratorFactory, [
    ServiceLifetime lifetime = ServiceLifetime.singleton,
  ]) {
    final builder = EmbeddingGeneratorBuilder.fromFactory(
      innerGeneratorFactory,
    );
    add(switch (lifetime) {
      ServiceLifetime.singleton =>
        ServiceDescriptor.singleton<EmbeddingGenerator>(
          (sp) => builder.build(sp),
        ),
      ServiceLifetime.scoped => ServiceDescriptor.scoped<EmbeddingGenerator>(
        (sp) => builder.build(sp),
      ),
      ServiceLifetime.transient =>
        ServiceDescriptor.transient<EmbeddingGenerator>(
          (sp) => builder.build(sp),
        ),
    });
    return builder;
  }
}

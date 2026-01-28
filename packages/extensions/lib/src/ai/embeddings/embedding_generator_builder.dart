import '../../dependency_injection/service_provider.dart';
import '../empty_service_provider.dart';
import 'embedding_generator.dart';

/// A factory that creates an [EmbeddingGenerator] from a [ServiceProvider].
typedef InnerEmbeddingGeneratorFactory = EmbeddingGenerator Function(
    ServiceProvider services);

/// Builds a pipeline of embedding generator middleware.
///
/// The pipeline is composed by calling [use] one or more times, then
/// calling [build] to produce the final [EmbeddingGenerator]. Middleware
/// factories are applied in reverse order so that the first call to
/// [use] produces the outermost wrapper.
class EmbeddingGeneratorBuilder {
  late final InnerEmbeddingGeneratorFactory _innerFactory;

  EmbeddingGeneratorBuilder._(InnerEmbeddingGeneratorFactory innerFactory)
      : _innerFactory = innerFactory;

  /// Creates a new [EmbeddingGeneratorBuilder] wrapping [innerGenerator].
  EmbeddingGeneratorBuilder(EmbeddingGenerator innerGenerator) {
    _innerFactory = (services) => innerGenerator;
  }

  /// Creates a new [EmbeddingGeneratorBuilder] from a factory function.
  factory EmbeddingGeneratorBuilder.fromFactory(
          InnerEmbeddingGeneratorFactory innerFactory) =>
      EmbeddingGeneratorBuilder._(innerFactory);

  final List<EmbeddingGenerator Function(EmbeddingGenerator)> _factories = [];

  /// Adds a middleware factory to the pipeline.
  EmbeddingGeneratorBuilder use(
      EmbeddingGenerator Function(EmbeddingGenerator) factory) {
    _factories.add(factory);
    return this;
  }

  /// Builds the pipeline and returns the outermost [EmbeddingGenerator].
  EmbeddingGenerator build([ServiceProvider? services]) {
    services ??= EmptyServiceProvider.instance;

    var generator = _innerFactory(services);
    for (var i = _factories.length - 1; i >= 0; i--) {
      generator = _factories[i](generator);
    }
    return generator;
  }
}

import 'embedding_generator_builder.dart';
import 'open_telemetry_embedding_generator.dart';

/// Extension methods for adding [OpenTelemetryEmbeddingGenerator] to a pipeline.
extension OpenTelemetryEmbeddingGeneratorBuilderExtensions
    on EmbeddingGeneratorBuilder {
  /// Adds an [OpenTelemetryEmbeddingGenerator] to the pipeline.
  EmbeddingGeneratorBuilder useOpenTelemetry(
          {String? modelId, String? system}) =>
      use((inner) => OpenTelemetryEmbeddingGenerator(inner,
          modelId: modelId, system: system));
}

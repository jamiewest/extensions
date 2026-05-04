import 'image_generator_builder.dart';
import 'open_telemetry_image_generator.dart';

/// Extension methods for adding [OpenTelemetryImageGenerator] to a pipeline.
extension OpenTelemetryImageGeneratorBuilderExtensions
    on ImageGeneratorBuilder {
  /// Adds an [OpenTelemetryImageGenerator] to the pipeline.
  ImageGeneratorBuilder useOpenTelemetry({String? modelId, String? system}) =>
      use((inner) =>
          OpenTelemetryImageGenerator(inner, modelId: modelId, system: system));
}

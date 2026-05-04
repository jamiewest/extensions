import '../../../../../lib/func_typedefs.dart';
import '../image/image_generator_builder.dart';
import 'open_telemetry_image_generator.dart';

/// Provides extensions for configuring [OpenTelemetryImageGenerator]
/// instances.
extension OpenTelemetryImageGeneratorBuilderExtensions on ImageGeneratorBuilder {
  /// Adds OpenTelemetry support to the image generator pipeline, following the
/// OpenTelemetry Semantic Conventions for Generative AI systems.
///
/// Remarks: The draft specification this follows is available at . The
/// specification is still experimental and subject to change; as such, the
/// telemetry output by this client is also subject to change.
///
/// Returns: The `builder`.
///
/// [builder] The [ImageGeneratorBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] to use to create a logger for
/// logging events.
///
/// [sourceName] An optional source name that will be used on the telemetry
/// data.
///
/// [configure] An optional callback that can be used to configure the
/// [OpenTelemetryImageGenerator] instance.
ImageGeneratorBuilder useOpenTelemetry({LoggerFactory? loggerFactory, String? sourceName, Action<OpenTelemetryImageGenerator>? configure, }) {
return Throw.ifNull(builder).use((innerGenerator, services) =>
        {
            loggerFactory ??= services.getService<LoggerFactory>();

            var g = openTelemetryImageGenerator(
              innerGenerator,
              loggerFactory?.createLogger(typeof(OpenTelemetryImageGenerator)),
              sourceName,
            );
            configure?.invoke(g);

            return g;
        });
 }
 }

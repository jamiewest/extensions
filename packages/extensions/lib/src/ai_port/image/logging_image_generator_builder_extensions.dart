import '../../../../../lib/func_typedefs.dart';
import 'image_generator_builder.dart';
import 'logging_image_generator.dart';

/// Provides extensions for configuring [LoggingImageGenerator] instances.
extension LoggingImageGeneratorBuilderExtensions on ImageGeneratorBuilder {
  /// Adds logging to the image generator pipeline.
///
/// Remarks: When the employed [Logger] enables [Trace], the contents of
/// prompts and options are logged. These prompts and options may contain
/// sensitive application data. [Trace] is disabled by default and should
/// never be enabled in a production environment. Prompts and options are not
/// logged at other logging levels.
///
/// Returns: The `builder`.
///
/// [builder] The [ImageGeneratorBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] used to create a logger with
/// which logging should be performed. If not supplied, a required instance
/// will be resolved from the service provider.
///
/// [configure] An optional callback that can be used to configure the
/// [LoggingImageGenerator] instance.
ImageGeneratorBuilder useLogging({LoggerFactory? loggerFactory, Action<LoggingImageGenerator>? configure, }) {
_ = Throw.ifNull(builder);
return builder.use((innerGenerator, services) =>
        {
            loggerFactory ??= services.getRequiredService<LoggerFactory>();

            // If the factory we resolve is for the null logger, the LoggingImageGenerator will end up
            // being an expensive nop, so skip adding it and just return the inner generator.
            if (loggerFactory == NullLoggerFactory.instance)
            {
                return innerGenerator;
            }

            var imageGenerator = loggingImageGenerator(
              innerGenerator,
              loggerFactory.createLogger(typeof(LoggingImageGenerator)),
            );
            configure?.invoke(imageGenerator);
            return imageGenerator;
        });
 }
 }

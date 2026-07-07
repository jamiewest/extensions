import '../../dependency_injection/service_provider_service_extensions.dart';
import '../../logging/logger_factory.dart';
import '../../logging/null_logger_factory.dart';
import 'image_generator_builder.dart';
import 'logging_image_generator.dart';

/// Provides extensions for adding [LoggingImageGenerator] to an
/// [ImageGeneratorBuilder] pipeline.
///
/// This is an experimental feature.
extension LoggingImageGeneratorBuilderExtensions on ImageGeneratorBuilder {
  /// Adds logging around image generation operations.
  ///
  /// When [loggerFactory] is omitted, it is resolved from the service
  /// provider at build time. When the resolved factory is the null logger
  /// factory, the generator is returned unwrapped.
  ImageGeneratorBuilder useLogging({
    LoggerFactory? loggerFactory,
    void Function(LoggingImageGenerator generator)? configure,
  }) =>
      useWithServices((inner, services) {
        loggerFactory ??= services.getRequiredService<LoggerFactory>();

        if (loggerFactory == NullLoggerFactory.instance) {
          return inner;
        }

        final generator = LoggingImageGenerator(
          inner,
          logger: loggerFactory!.createLogger('LoggingImageGenerator'),
        );
        configure?.call(generator);
        return generator;
      });
}

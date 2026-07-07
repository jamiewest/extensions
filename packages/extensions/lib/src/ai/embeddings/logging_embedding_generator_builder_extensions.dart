import '../../dependency_injection/service_provider_service_extensions.dart';
import '../../logging/logger_factory.dart';
import '../../logging/null_logger_factory.dart';
import 'embedding_generator_builder.dart';
import 'logging_embedding_generator.dart';

/// Provides extensions for adding [LoggingEmbeddingGenerator] to an
/// [EmbeddingGeneratorBuilder] pipeline.
extension LoggingEmbeddingGeneratorBuilderExtensions
    on EmbeddingGeneratorBuilder {
  /// Adds logging around embedding generation operations.
  ///
  /// When [loggerFactory] is omitted, it is resolved from the service
  /// provider at build time. When the resolved factory is the null logger
  /// factory, the generator is returned unwrapped.
  EmbeddingGeneratorBuilder useLogging({
    LoggerFactory? loggerFactory,
    void Function(LoggingEmbeddingGenerator generator)? configure,
  }) =>
      useWithServices((inner, services) {
        loggerFactory ??= services.getRequiredService<LoggerFactory>();

        if (loggerFactory == NullLoggerFactory.instance) {
          return inner;
        }

        final generator = LoggingEmbeddingGenerator(
          inner,
          logger: loggerFactory!.createLogger('LoggingEmbeddingGenerator'),
        );
        configure?.call(generator);
        return generator;
      });
}

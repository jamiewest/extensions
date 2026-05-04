import '../../../../../lib/func_typedefs.dart';
import 'embedding_generator_builder.dart';
import 'logging_embedding_generator.dart';

/// Provides extensions for configuring [LoggingEmbeddingGenerator] instances.
extension LoggingEmbeddingGeneratorBuilderExtensions on EmbeddingGeneratorBuilder<TInput, TEmbedding> {
  /// Adds logging to the embedding generator pipeline.
///
/// Remarks: When the employed [Logger] enables [Trace], the contents of
/// values and options are logged. These values and options may contain
/// sensitive application data. [Trace] is disabled by default and should
/// never be enabled in a production environment. Messages and options are not
/// logged at other logging levels.
///
/// Returns: The `builder`.
///
/// [builder] The [EmbeddingGeneratorBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] used to create a logger with
/// which logging should be performed. If not supplied, a required instance
/// will be resolved from the service provider.
///
/// [configure] An optional callback that can be used to configure the
/// [LoggingEmbeddingGenerator] instance.
///
/// [TInput] Specifies the type of the input passed to the generator.
///
/// [TEmbedding] Specifies the type of the embedding instance produced by the
/// generator.
EmbeddingGeneratorBuilder<TInput, TEmbedding> useLogging<TEmbedding>({LoggerFactory? loggerFactory, Action<LoggingEmbeddingGenerator<TInput, TEmbedding>>? configure, }) {
_ = Throw.ifNull(builder);
return builder.use((innerGenerator, services) =>
        {
            loggerFactory ??= services.getRequiredService<LoggerFactory>();

            // If the factory we resolve is for the null logger, the LoggingEmbeddingGenerator will end up
            // being an expensive nop, so skip adding it and just return the inner generator.
            if (loggerFactory == NullLoggerFactory.instance)
            {
                return innerGenerator;
            }

            var generator = new LoggingEmbeddingGenerator<TInput, TEmbedding>(
              innerGenerator,
              loggerFactory.createLogger(typeof(LoggingEmbeddingGenerator<TInput, TEmbedding>)),
            );
            configure?.invoke(generator);
            return generator;
        });
 }
 }
